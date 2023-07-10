package com.authentrend.flutter_passkey

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.os.Build
import android.util.Base64
import android.util.Log
import androidx.annotation.NonNull
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CreatePublicKeyCredentialResponse
import androidx.credentials.CredentialManager
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.gms.fido.Fido
import com.google.android.gms.fido.fido2.api.common.AuthenticatorAssertionResponse
import com.google.android.gms.fido.fido2.api.common.PublicKeyCredentialDescriptor
import com.google.android.gms.fido.fido2.api.common.PublicKeyCredentialRequestOptions
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.FlutterException
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.launch
import org.json.JSONObject


/** FlutterPasskeyPlugin */
class FlutterPasskeyPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
  PluginRegistry.ActivityResultListener, ViewModel() {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  @SuppressLint("StaticFieldLeak")
  private var activity: Activity? = null
  private lateinit var _result: Result


  companion object {
    private const val LOG_TAG = "Fido2Demo"
    private const val REQUEST_CODE_REGISTER = 1
    private const val REQUEST_CODE_SIGN = 2
    private const val KEY_HANDLE_PREF = "key_handle"
  }

  private fun getPlatformVersion(): String {
    return "Android ${Build.VERSION.RELEASE}"
  }

  private fun createCredential(
    options: String,
    callback: (credential: String?, e: Exception?) -> Unit
  ) {
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
          context = activity!!,
        )
        val credential = result as CreatePublicKeyCredentialResponse
        callback(credential.registrationResponseJson, null)
      } catch (e: Exception) {
        callback(null, e)
      }
    }
  }

  private fun signFido2(options: String) {
    // All the option parameters should come from the Relying Party / server

    // check if options is a valid json string
    val jsonObj = JSONObject(options)
    val challengeString = jsonObj.getString("challenge")
    val byteArray = if (isBase64UrlEncoded(challengeString)) {
      decodeBase64Url(challengeString)
    } else {
      challengeString.toByteArray()
    }
    val allowedCredentials = jsonObj.getJSONArray("allowed_credentials")
    val publicKeys = ArrayList<PublicKeyCredentialDescriptor>()
    for (i in 0 until allowedCredentials.length()) {
      val cred = allowedCredentials.getJSONObject(i)
      val idString = cred.getString("id")
      val id = if (isBase64UrlEncoded(idString)) {
        decodeBase64Url(idString)
      } else {
        idString.toByteArray()
      }
      publicKeys.add(
        element = PublicKeyCredentialDescriptor(
          cred.getString("type"),
          id,
          null,
        )

      )
    }

    val requestOptions = PublicKeyCredentialRequestOptions.Builder()
      .setChallenge(byteArray)
      .setRpId(jsonObj.getString("rpId"))
      .setAllowList(publicKeys)
      .setTimeoutSeconds(jsonObj.getDouble("timeout"))
      .build()


    val fido2ApiClient = Fido.getFido2ApiClient(activity!!)
    val fido2PendingIntentTask = fido2ApiClient.getSignPendingIntent(requestOptions)
    fido2PendingIntentTask.addOnSuccessListener { pendingIntent ->
      if (pendingIntent != null) {
        // Start a FIDO2 sign request.
        activity!!.startIntentSenderForResult(
          pendingIntent.intentSender,
          REQUEST_CODE_SIGN,
          null, // fillInIntent
          0, // flagsMask
          0, // flagsValue
          0 // extraFlags
        )
      }
    }
    fido2PendingIntentTask.addOnFailureListener { e ->
      print(e)
      // Fail
    }
  }

  private fun decodeBase64Url(encoded: String): ByteArray {
    return Base64.decode(encoded, Base64.URL_SAFE)
  }

  private fun isBase64UrlEncoded(input: String): Boolean {
    return try {
      Base64.decode(input, Base64.URL_SAFE)
      true
    } catch (e: IllegalArgumentException) {
      false
    }
  }

  private fun getCredential(
    options: String,
    callback: (credential: String?, e: Exception?) -> Unit
  ) {
    if (activity == null) {
      throw IllegalStateException("Activity not found")
    }

    signFido2(options)
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_passkey")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
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
            } else if (e != null) {
              result.error(
                e.javaClass.kotlin.simpleName ?: "Exception",
                e.message ?: "Exception occurred",
                null
              )
            } else {
              result.error("Error", "Unknown error", null)
            }
          }
        } catch (e: Exception) {
          result.error(
            e.javaClass.kotlin.simpleName ?: "Exception",
            e.message ?: "Exception occurred",
            null
          )
        }
      }

      "getCredential" -> {
        _result = result;
        val options = call.argument("options") as String?
        if (options == null) {
          result.error("InvalidParameterException", "Options not found", null)
          return
        }
        try {
          signFido2(options)
        } catch (e: Exception) {
          result.error(
            e.javaClass.kotlin.simpleName ?: "Exception",
            e.message ?: "Exception occurred",
            null
          )
        }
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  private fun handleSignResponse(fido2Response: ByteArray) {
    try {
      val res =
        com.google.android.gms.fido.fido2.api.common.PublicKeyCredential.deserializeFromBytes(
          fido2Response
        )
      val response = res.response as AuthenticatorAssertionResponse

      val keyHandleBase64 = Base64.encodeToString(res.rawId, Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP)
      val clientDataJson = Base64.encodeToString(response.clientDataJSON, Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP)
      val authenticatorDataBase64 =
        Base64.encodeToString(response.authenticatorData, Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP)
      val signatureBase64 = Base64.encodeToString(response.signature, Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP)

      Log.d(LOG_TAG, "keyHandleBase64: $keyHandleBase64")
      Log.d(LOG_TAG, "clientDataJSON: $clientDataJson")
      Log.d(LOG_TAG, "authenticatorDataBase64: $authenticatorDataBase64")
      Log.d(LOG_TAG, "signatureBase64: $signatureBase64")

      val jsonResult = JSONObject()
      val jsonResponse = JSONObject()
      jsonResponse.put("authenticatorData", authenticatorDataBase64)
      jsonResponse.put("signature", signatureBase64)
      jsonResponse.put("clientDataJSON", clientDataJson)
      jsonResponse.put("userHandle", "")
      jsonResult.put("id", keyHandleBase64)
      jsonResult.put("rawId", keyHandleBase64)
      jsonResult.put("type", "public-key")
      jsonResult.put("response", jsonResponse)

      _result.success(jsonResult.toString())
    } catch (e: Exception) {
      _result.error("Error", "Sign in failed", e)
    }

  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    when (resultCode) {
      FlutterFragmentActivity.RESULT_OK -> {
        data?.let {
          if (it.hasExtra(Fido.FIDO2_KEY_CREDENTIAL_EXTRA)) {
            handleSignResponse(data.getByteArrayExtra(Fido.FIDO2_KEY_CREDENTIAL_EXTRA)!!)
          }
        }
      }

      FlutterFragmentActivity.RESULT_CANCELED -> {
        val result = "Operation is cancelled"
        _result.error("RESULT_CANCELED", result, "RESULT_CANCELED")
      }

      else -> {
        val result = "Operation failed, with resultCode: $resultCode"
        _result.error("FAILED", result, "$resultCode")
      }
    }

    return false
  }

}
