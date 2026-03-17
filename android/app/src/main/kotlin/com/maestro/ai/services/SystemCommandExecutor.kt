package com.maestro.ai.services

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioManager
import android.net.Uri
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.os.PowerManager
import android.os.StatFs
import android.provider.Settings
import android.telephony.SmsManager
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.content.ContextCompat
import java.io.File

class SystemCommandExecutor(private val context: Context) {
    
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
    private val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    private val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
    
    fun executeCommand(command: String, params: Map<String, Any>): Map<String, Any> {
        return when (command) {
            // App Commands
            "OPEN_APP" -> openApp(params["packageName"] as? String ?: "")
            "CLOSE_APP" -> closeApp(params["packageName"] as? String ?: "")
            "GET_APPS" -> getInstalledApps()
            
            // Call Commands
            "MAKE_CALL" -> makeCall(params["phoneNumber"] as? String ?: "")
            "END_CALL" -> endCall()
            "MUTE_CALL" -> muteCall()
            "SPEAKER_ON" -> setSpeakerphone(true)
            
            // SMS Commands
            "SEND_SMS" -> sendSms(
                params["phoneNumber"] as? String ?: "",
                params["message"] as? String ?: ""
            )
            
            // Settings Commands
            "TOGGLE_WIFI" -> toggleWifi(params["enable"] as? Boolean ?: false)
            "TOGGLE_BLUETOOTH" -> toggleBluetooth(params["enable"] as? Boolean ?: false)
            "TOGGLE_LOCATION" -> toggleLocation(params["enable"] as? Boolean ?: false)
            "TOGGLE_AIRPLANE" -> toggleAirplaneMode(params["enable"] as? Boolean ?: false)
            "SET_BRIGHTNESS" -> setBrightness(params["level"] as? Int ?: 128)
            "SET_VOLUME" -> setVolume(params["level"] as? Int ?: 50, params["stream"] as? Int ?: AudioManager.STREAM_MUSIC)
            "TOGGLE_SILENT" -> toggleSilentMode(params["enable"] as? Boolean ?: false)
            "TOGGLE_DND" -> toggleDndMode(params["enable"] as? Boolean ?: false)
            
            // File Commands
            "LIST_FILES" -> listFiles(params["path"] as? String ?: "")
            "CREATE_FOLDER" -> createFolder(params["path"] as? String ?: "")
            "DELETE_FILE" -> deleteFile(params["path"] as? String ?: "")
            "COPY_FILE" -> copyFile(
                params["source"] as? String ?: "",
                params["destination"] as? String ?: ""
            )
            "MOVE_FILE" -> moveFile(
                params["source"] as? String ?: "",
                params["destination"] as? String ?: ""
            )
            
            // Media Commands
            "PLAY_MEDIA" -> playMedia(params["path"] as? String ?: "")
            "PAUSE_MEDIA" -> pauseMedia()
            "NEXT_TRACK" -> nextTrack()
            "PREVIOUS_TRACK" -> previousTrack()
            "TAKE_PHOTO" -> takePhoto()
            "RECORD_VIDEO" -> recordVideo()
            
            // System Commands
            "BATTERY_STATUS" -> getBatteryStatus()
            "STORAGE_INFO" -> getStorageInfo()
            "MEMORY_INFO" -> getMemoryInfo()
            "DEVICE_INFO" -> getDeviceInfo()
            "REBOOT" -> rebootDevice()
            "SHUTDOWN" -> shutdownDevice()
            "CLEAR_RAM" -> clearRam()
            "CLOSE_ALL_APPS" -> closeAllApps()
            
            // Accessibility Commands
            "READ_SCREEN" -> readScreen()
            "INCREASE_FONT" -> changeFontSize(true)
            "DECREASE_FONT" -> changeFontSize(false)
            "TOGGLE_TALKBACK" -> toggleTalkBack()
            
            else -> mapOf("success" to false, "error" to "Unknown command")
        }
    }
    
    private fun openApp(packageName: String): Map<String, Any> {
        return try {
            val intent = context.packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                mapOf("success" to true)
            } else {
                mapOf("success" to false, "error" to "App not found")
            }
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun closeApp(packageName: String): Map<String, Any> {
        return try {
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            am.killBackgroundProcesses(packageName)
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun getInstalledApps(): Map<String, Any> {
        return try {
            val pm = context.packageManager
            val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
                .filter { it.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM == 0 }
                .map { app ->
                    mapOf(
                        "name" to pm.getApplicationLabel(app).toString(),
                        "packageName" to app.packageName,
                        "icon" to app.icon
                    )
                }
            mapOf("success" to true, "apps" to apps)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun makeCall(phoneNumber: String): Map<String, Any> {
        return try {
            val intent = Intent(Intent.ACTION_CALL, Uri.parse("tel:$phoneNumber"))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun endCall(): Map<String, Any> {
        return try {
            val telephonyService = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            // Note: Ending calls programmatically requires special permissions on newer Android versions
            mapOf("success" to true, "message" to "Call end requested")
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun muteCall(): Map<String, Any> {
        return try {
            audioManager.mode = AudioManager.MODE_IN_CALL
            audioManager.isMicrophoneMute = true
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun setSpeakerphone(enable: Boolean): Map<String, Any> {
        return try {
            audioManager.mode = AudioManager.MODE_IN_CALL
            audioManager.isSpeakerphoneOn = enable
            mapOf("success" to true, "speakerOn" to enable)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun sendSms(phoneNumber: String, message: String): Map<String, Any> {
        return try {
            val smsManager = SmsManager.getDefault()
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun toggleWifi(enable: Boolean): Map<String, Any> {
        return try {
            wifiManager.isWifiEnabled = enable
            mapOf("success" to true, "status" to enable)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun toggleBluetooth(enable: Boolean): Map<String, Any> {
        return try {
            if (bluetoothAdapter != null) {
                if (enable) {
                    bluetoothAdapter.enable()
                } else {
                    bluetoothAdapter.disable()
                }
                mapOf("success" to true, "status" to enable)
            } else {
                mapOf("success" to false, "error" to "Bluetooth not supported")
            }
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun toggleLocation(enable: Boolean): Map<String, Any> {
        return try {
            val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            mapOf("success" to true, "message" to "Location settings opened")
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun toggleAirplaneMode(enable: Boolean): Map<String, Any> {
        return try {
            val intent = Intent(Settings.ACTION_AIRPLANE_MODE_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            mapOf("success" to true, "message" to "Airplane mode settings opened")
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun setBrightness(level: Int): Map<String, Any> {
        return try {
            val newLevel = level.coerceIn(0, 255)
            Settings.System.putInt(
                context.contentResolver,
                Settings.System.SCREEN_BRIGHTNESS,
                newLevel
            )
            mapOf("success" to true, "level" to newLevel)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun setVolume(level: Int, stream: Int): Map<String, Any> {
        return try {
            val maxVolume = audioManager.getStreamMaxVolume(stream)
            val newLevel = (level * maxVolume / 100).coerceIn(0, maxVolume)
            audioManager.setStreamVolume(stream, newLevel, 0)
            mapOf("success" to true, "level" to newLevel, "max" to maxVolume)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun toggleSilentMode(enable: Boolean): Map<String, Any> {
        return try {
            val newMode = if (enable) AudioManager.RINGER_MODE_SILENT else AudioManager.RINGER_MODE_NORMAL
            audioManager.ringerMode = newMode
            mapOf("success" to true, "mode" to newMode)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun toggleDndMode(enable: Boolean): Map<String, Any> {
        return try {
            val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            mapOf("success" to true, "message" to "DND settings opened")
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun listFiles(path: String): Map<String, Any> {
        return try {
            val directory = File(path)
            if (directory.exists() && directory.isDirectory) {
                val files = directory.listFiles()?.map { file ->
                    mapOf(
                        "name" to file.name,
                        "path" to file.absolutePath,
                        "isDirectory" to file.isDirectory,
                        "size" to file.length(),
                        "lastModified" to file.lastModified()
                    )
                } ?: emptyList()
                mapOf("success" to true, "files" to files)
            } else {
                mapOf("success" to false, "error" to "Directory not found")
            }
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun createFolder(path: String): Map<String, Any> {
        return try {
            val folder = File(path)
            val success = folder.mkdirs()
            mapOf("success" to success, "path" to path)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun deleteFile(path: String): Map<String, Any> {
        return try {
            val file = File(path)
            val success = file.delete()
            mapOf("success" to success)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun copyFile(source: String, destination: String): Map<String, Any> {
        return try {
            val srcFile = File(source)
            val destFile = File(destination)
            srcFile.copyTo(destFile, overwrite = true)
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun moveFile(source: String, destination: String): Map<String, Any> {
        return try {
            val srcFile = File(source)
            val destFile = File(destination)
            srcFile.renameTo(destFile)
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun playMedia(path: String): Map<String, Any> {
        return try {
            val intent = Intent(Intent.ACTION_VIEW)
            val uri = Uri.parse(path)
            intent.setDataAndType(uri, "audio/*")
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun pauseMedia(): Map<String, Any> {
        return try {
            val intent = Intent("android.intent.action.MEDIA_BUTTON")
            intent.putExtra("android.intent.extra.KEY_EVENT", 
                android.view.KeyEvent(android.view.KeyEvent.ACTION_DOWN, android.view.KeyEvent.KEYCODE_MEDIA_PAUSE))
            context.sendBroadcast(intent)
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun nextTrack(): Map<String, Any> {
        return try {
            val intent = Intent("android.intent.action.MEDIA_BUTTON")
            intent.putExtra("android.intent.extra.KEY_EVENT", 
                android.view.KeyEvent(android.view.KeyEvent.ACTION_DOWN, android.view.KeyEvent.KEYCODE_MEDIA_NEXT))
            context.sendBroadcast(intent)
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun previousTrack(): Map<String, Any> {
        return try {
            val intent = Intent("android.intent.action.MEDIA_BUTTON")
            intent.putExtra("android.intent.extra.KEY_EVENT", 
                android.view.KeyEvent(android.view.KeyEvent.ACTION_DOWN, android.view.KeyEvent.KEYCODE_MEDIA_PREVIOUS))
            context.sendBroadcast(intent)
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun takePhoto(): Map<String, Any> {
        return try {
            val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun recordVideo(): Map<String, Any> {
        return try {
            val intent = Intent(MediaStore.ACTION_VIDEO_CAPTURE)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun getBatteryStatus(): Map<String, Any> {
        val batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        val isCharging = batteryManager.isCharging
        
        return mapOf(
            "success" to true,
            "level" to batteryLevel,
            "isCharging" to isCharging
        )
    }
    
    private fun getStorageInfo(): Map<String, Any> {
        val path = File(context.filesDir.absolutePath)
        val stat = StatFs(path.path)
        val blockSize = stat.blockSizeLong
        val totalBlocks = stat.blockCountLong
        val availableBlocks = stat.availableBlocksLong
        
        return mapOf(
            "success" to true,
            "total" to (totalBlocks * blockSize),
            "available" to (availableBlocks * blockSize),
            "used" to ((totalBlocks - availableBlocks) * blockSize)
        )
    }
    
    private fun getMemoryInfo(): Map<String, Any> {
        return try {
            val mi = android.app.ActivityManager.MemoryInfo()
            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            activityManager.getMemoryInfo(mi)
            
            mapOf(
                "success" to true,
                "totalRam" to mi.totalMem,
                "availableRam" to mi.availMem,
                "isLowMemory" to mi.lowMemory
            )
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun getDeviceInfo(): Map<String, Any> {
        return mapOf(
            "success" to true,
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkVersion" to Build.VERSION.SDK_INT,
            "brand" to Build.BRAND,
            "device" to Build.DEVICE,
            "product" to Build.PRODUCT
        )
    }
    
    private fun rebootDevice(): Map<String, Any> {
        return try {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            // Note: Reboot requires special system permissions
            mapOf("success" to false, "error" to "Reboot requires system permissions")
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun shutdownDevice(): Map<String, Any> {
        return try {
            // Note: Shutdown requires special system permissions
            mapOf("success" to false, "error" to "Shutdown requires system permissions")
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun clearRam(): Map<String, Any> {
        return try {
            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            activityManager.clearApplicationUserData()
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun closeAllApps(): Map<String, Any> {
        return try {
            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            activityManager.runningAppProcesses?.forEach { process ->
                if (process.importance > android.app.ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                    android.os.Process.killProcess(process.pid)
                }
            }
            mapOf("success" to true)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun readScreen(): Map<String, Any> {
        val text = MaestroAccessibilityService.instance?.getCurrentScreenText() ?: ""
        return mapOf("success" to true, "text" to text)
    }
    
    private fun changeFontSize(increase: Boolean): Map<String, Any> {
        return try {
            val currentSize = Settings.System.getFloat(context.contentResolver, Settings.System.FONT_SCALE)
            val newSize = if (increase) currentSize + 0.1f else currentSize - 0.1f
            Settings.System.putFloat(context.contentResolver, Settings.System.FONT_SCALE, newSize.coerceIn(0.5f, 2.0f))
            mapOf("success" to true, "fontScale" to newSize)
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
    
    private fun toggleTalkBack(): Map<String, Any> {
        return try {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            mapOf("success" to true, "message" to "Accessibility settings opened")
        } catch (e: Exception) {
            mapOf("success" to false, "error" to e.message)
        }
    }
}
