package com.onceagain.drinksomewater.service.health

import android.content.Context
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.HydrationRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.WeightRecord
import androidx.health.connect.client.records.metadata.Metadata
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.response.ReadRecordsResponse
import androidx.health.connect.client.units.kilograms
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import java.time.Instant
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

@OptIn(ExperimentalCoroutinesApi::class)
class HealthConnectHelperTest {
    private val context: Context = mockk()
    private val healthConnectClient: HealthConnectClient = mockk()
    private val permissionController: PermissionController = mockk()

    private val testDispatcher = StandardTestDispatcher()

    private val readPermission = HealthPermission.getReadPermission(WeightRecord::class)
    private val writePermission = HealthPermission.getWritePermission(HydrationRecord::class)

    @BeforeEach
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        every { healthConnectClient.permissionController } returns permissionController
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    private fun createHelper(sdkStatus: Int = HealthConnectClient.SDK_AVAILABLE): HealthConnectHelper {
        return HealthConnectHelper(context, healthConnectClient) { sdkStatus }
    }

    @Test
    fun `checkAvailability returns true when sdk available`() {
        val helper = createHelper()

        assertTrue(helper.checkAvailability())
    }

    @Test
    fun `checkAvailability returns false when sdk unavailable`() {
        val helper = createHelper(HealthConnectClient.SDK_UNAVAILABLE)

        assertFalse(helper.checkAvailability())
    }

    @Test
    fun `requestPermissions returns true when permissions already granted`() = runTest {
        val helper = createHelper()
        val launcher: ActivityResultLauncher<Set<String>> = mockk(relaxed = true)

        coEvery { permissionController.getGrantedPermissions() } returns setOf(readPermission, writePermission)

        val result = helper.requestPermissions(launcher)

        assertTrue(result)
        verify(exactly = 0) { launcher.launch(any()) }
    }

    @Test
    fun `requestPermissions launches when permissions missing`() = runTest {
        val helper = createHelper()
        val launcher: ActivityResultLauncher<Set<String>> = mockk(relaxed = true)

        coEvery { permissionController.getGrantedPermissions() } returns setOf(readPermission)

        val result = helper.requestPermissions(launcher)

        assertFalse(result)
        verify { launcher.launch(setOf(readPermission, writePermission)) }
    }

    @Test
    fun `requestPermissions returns false when sdk unavailable`() = runTest {
        val helper = createHelper(HealthConnectClient.SDK_UNAVAILABLE)
        val launcher: ActivityResultLauncher<Set<String>> = mockk(relaxed = true)

        val result = helper.requestPermissions(launcher)

        assertFalse(result)
        verify(exactly = 0) { launcher.launch(any()) }
    }

    @Test
    fun `getLatestWeight returns weight when permissions granted`() = runTest {
        val helper = createHelper()
        val weightRecord = WeightRecord(
            time = Instant.parse("2026-01-20T00:00:00Z"),
            zoneOffset = null,
            metadata = Metadata(recordingMethod = Metadata.RECORDING_METHOD_MANUAL_ENTRY),
            weight = 70.5.kilograms
        )
        val response: ReadRecordsResponse<WeightRecord> = mockk()

        coEvery { permissionController.getGrantedPermissions() } returns setOf(readPermission)
        every { response.records } returns listOf(weightRecord)
        coEvery { healthConnectClient.readRecords(any<ReadRecordsRequest<WeightRecord>>()) } returns response

        val result = helper.getLatestWeight()

        assertEquals(70.5f, result)
    }

    @Test
    fun `getLatestWeight returns null when permission missing`() = runTest {
        val helper = createHelper()

        coEvery { permissionController.getGrantedPermissions() } returns emptySet()

        val result = helper.getLatestWeight()

        assertNull(result)
        coVerify(exactly = 0) { healthConnectClient.readRecords(any<ReadRecordsRequest<WeightRecord>>()) }
    }

    @Test
    fun `calculateRecommendedIntake returns weight based amount`() {
        val helper = createHelper()

        val result = helper.calculateRecommendedIntake(70f)

        assertEquals(2310, result)
    }

    @Test
    fun `writeHydrationRecord writes record when permission granted`() = runTest {
        val helper = createHelper()
        val timestamp = Instant.parse("2026-01-20T08:00:00Z")
        val recordSlot = slot<List<Record>>()

        coEvery { permissionController.getGrantedPermissions() } returns setOf(writePermission)
        coEvery { healthConnectClient.insertRecords(any()) } returns mockk()

        val result = helper.writeHydrationRecord(250, timestamp)

        assertTrue(result)
        coVerify { healthConnectClient.insertRecords(capture(recordSlot)) }
        val record = recordSlot.captured.first() as HydrationRecord
        assertEquals(timestamp, record.startTime)
        assertEquals(0.25, record.volume.inLiters, 0.0001)
    }

    @Test
    fun `writeHydrationRecord returns false when permission missing`() = runTest {
        val helper = createHelper()
        val timestamp = Instant.parse("2026-01-20T08:00:00Z")

        coEvery { permissionController.getGrantedPermissions() } returns emptySet()

        val result = helper.writeHydrationRecord(250, timestamp)

        assertFalse(result)
        coVerify(exactly = 0) { healthConnectClient.insertRecords(any<List<Record>>()) }
    }
}
