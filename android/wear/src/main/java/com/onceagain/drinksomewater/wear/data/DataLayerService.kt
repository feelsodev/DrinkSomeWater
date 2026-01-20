package com.onceagain.drinksomewater.wear.data

import android.content.Context
import com.google.android.gms.wearable.MessageClient
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.Wearable
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class DataLayerService @Inject constructor(
    @ApplicationContext context: Context
) : MessageClient.OnMessageReceivedListener {

    private val messageClient = Wearable.getMessageClient(context)
    private val nodeClient = Wearable.getNodeClient(context)
    private var messageListener: ((MessageEvent) -> Unit)? = null

    fun sendAddWater(amount: Int) {
        sendMessage(PATH_ADD_WATER, amount.toString().encodeToByteArray())
    }

    fun sendSyncRequest() {
        sendMessage(PATH_SYNC_REQUEST, ByteArray(0))
    }

    fun startListening(onMessageReceived: (MessageEvent) -> Unit) {
        messageListener = onMessageReceived
        messageClient.addListener(this)
    }

    fun stopListening() {
        messageListener = null
        messageClient.removeListener(this)
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        messageListener?.invoke(messageEvent)
    }

    private fun sendMessage(path: String, payload: ByteArray) {
        nodeClient.connectedNodes.addOnSuccessListener { nodes ->
            nodes.forEach { node ->
                messageClient.sendMessage(node.id, path, payload)
            }
        }
    }

    companion object {
        const val PATH_ADD_WATER = "/water/add"
        const val PATH_SYNC_REQUEST = "/water/sync_request"
        const val PATH_SYNC = "/water/sync"
    }
}
