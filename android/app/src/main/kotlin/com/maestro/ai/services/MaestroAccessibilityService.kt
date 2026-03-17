package com.maestro.ai.services

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log

class MaestroAccessibilityService : AccessibilityService() {
    
    companion object {
        var instance: MaestroAccessibilityService? = null
        var isServiceEnabled = false
    }
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        isServiceEnabled = true
        
        val info = AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPES_ALL_MASK
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
        info.flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        serviceInfo = info
        
        Log.d("MaestroAI", "Accessibility Service Connected")
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                // تم تغيير النافذة - يمكن استخدامه لمعرفة التطبيق المفتوح
                val packageName = event.packageName
                val className = event.className
                Log.d("MaestroAI", "Opened: $packageName / $className")
            }
            
            AccessibilityEvent.TYPE_VIEW_CLICKED -> {
                // تم النقر على عنصر
                Log.d("MaestroAI", "Clicked: ${event.text}")
            }
            
            AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED -> {
                // تغير النص
                Log.d("MaestroAI", "Text changed: ${event.text}")
            }
        }
    }
    
    override fun onInterrupt() {
        Log.d("MaestroAI", "Accessibility Service Interrupted")
    }
    
    override fun onDestroy() {
        super.onDestroy()
        instance = null
        isServiceEnabled = false
    }
    
    fun getCurrentScreenText(): String {
        val rootNode = rootInActiveWindow ?: return ""
        return extractTextFromNode(rootNode)
    }
    
    private fun extractTextFromNode(node: AccessibilityNodeInfo): String {
        val text = StringBuilder()
        
        if (node.text != null) {
            text.append(node.text).append("\n")
        }
        
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                text.append(extractTextFromNode(child))
                child.recycle()
            }
        }
        
        return text.toString()
    }
    
    fun performClickOnText(targetText: String): Boolean {
        val rootNode = rootInActiveWindow ?: return false
        return findAndClickNode(rootNode, targetText)
    }
    
    private fun findAndClickNode(node: AccessibilityNodeInfo, targetText: String): Boolean {
        if (node.text != null && node.text.toString().contains(targetText, ignoreCase = true)) {
            return node.performAction(AccessibilityNodeInfo.ACTION_CLICK)
        }
        
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                if (findAndClickNode(child, targetText)) {
                    child.recycle()
                    return true
                }
                child.recycle()
            }
        }
        
        return false
    }
    
    fun performScroll(direction: Int): Boolean {
        val rootNode = rootInActiveWindow ?: return false
        return rootNode.performAction(direction)
    }
    
    fun findNodesByText(text: String): List<AccessibilityNodeInfo> {
        val nodes = mutableListOf<AccessibilityNodeInfo>()
        val rootNode = rootInActiveWindow ?: return nodes
        findNodesRecursive(rootNode, text, nodes)
        return nodes
    }
    
    private fun findNodesRecursive(node: AccessibilityNodeInfo, text: String, result: MutableList<AccessibilityNodeInfo>) {
        if (node.text != null && node.text.toString().contains(text, ignoreCase = true)) {
            result.add(node)
        }
        
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                findNodesRecursive(child, text, result)
            }
        }
    }
}
