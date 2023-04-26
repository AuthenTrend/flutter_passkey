package com.authentrend.flutter_passkey

import android.app.Activity
import androidx.annotation.NonNull
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CreatePublicKeyCredentialResponse
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.PublicKeyCredential
import androidx.credentials.exceptions.CreateCredentialException
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.security.InvalidParameterException

/** FlutterPasskeyPlugin */
class FlutterPasskeyPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, ViewModel() {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private var activity: Activity? = null

  private fun getPlatformVersion(): String {
    return "Android ${android.os.Build.VERSION.RELEASE}"
  }

  private fun createCredential(@NonNull options: String, @NonNull callback: (credential: String?, e: Exception?) -> Unit) {
    if (activity == null) {
      throw IllegalStateException("Activity not found")
    }
    JSONObject(options) // check if options is a valid json string
    val createPublicKeyCredentialRequest = CreatePublicKeyCredentialRequest(
      requestJson = options,
      preferImmediatelyAvailableCredentials = false
    )
    viewModelScope.launch {
      try {
        val credentialManager = CredentialManager.create(activity!!)
        val result = credentialManager.createCredential(
          request = createPublicKeyCredentialRequest,
          activity = activity!!,
        )
        val credential = result as CreatePublicKeyCredentialResponse
        callback(credential.registrationResponseJson, null)
      } catch (e: Exception) {
        callback(null, e)
      }
    }
  }

  private fun getCredential(@NonNull options: String, @NonNull callback: (credential: String?, e: Exception?) -> Unit) {
    if (activity == null) {
      throw IllegalStateException("Activity not found")
    }
    JSONObject(options) // check if options is a valid json string
    val getPublicKeyCredentialOption = GetPublicKeyCredentialOption(
      requestJson = options,
      preferImmediatelyAvailableCredentials = false
    )
    viewModelScope.launch {
      try {
        val credentialManager = CredentialManager.create(activity!!)
        val result = credentialManager.getCredential(
          request = GetCredentialRequest(listOf(getPublicKeyCredentialOption)),
          activity = activity!!,
        )
        val credential = result.credential as PublicKeyCredential
        callback(credential.authenticationResponseJson, null)
      } catch (e: Exception) {
        callback(null, e)
      }
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_passkey")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success(getPlatformVersion())
      "createCredential" -> {
        val options = call.argument("options") as String?
        if (options == null) {
          result.error("InvalidParameterException", "Options not found", null)
          return
        }
        try {
          createCredential(options) { credential, e ->
            if (credential != null) {
              result.success(credential)
            }
            else if (e != null) {
              result.error(e.javaClass.kotlin.simpleName ?: "Exception", e.message ?: "Exception occurred", null)
            }
            else {
              result.error("Error", "Unknown error", null)
            }
          }
        } catch (e: Exception) {
          result.error(e.javaClass.kotlin.simpleName ?: "Exception", e.message ?: "Exception occurred", null)
        }
      }
      "getCredential" -> {
        val options = call.argument("options") as String?
        if (options == null) {
          result.error("InvalidParameterException", "Options not found", null)
          return
        }
        try {
          getCredential(options) { credential, e ->
            if (credential != null) {
              result.success(credential)
            }
            else if (e != null) {
              result.error(e.javaClass.kotlin.simpleName ?: "Exception", e.message ?: "Exception occurred", null)
            }
            else {
              result.error("Error", "Unknown error", null)
            }
          }
        } catch (e: Exception) {
          result.error(e.javaClass.kotlin.simpleName ?: "Exception", e.message ?: "Exception occurred", null)
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.getActivity()
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.getActivity()
  }
}
