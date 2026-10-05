package com.hardwarescan.desktop.data

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import oshi.SystemInfo
import oshi.hardware.CentralProcessor
import oshi.hardware.GlobalMemory
import oshi.hardware.GraphicsCard
import oshi.hardware.HWDiskStore
import oshi.hardware.NetworkIF
import oshi.hardware.PhysicalMemory
import oshi.hardware.SoundCard
import oshi.hardware.UsbDevice
import oshi.software.os.OSFileStore
import java.awt.GraphicsEnvironment

data class CpuSnapshot(
    val model: String,
    val vendor: String,
    val family: String,
    val stepping: String,
    val processorId: String,
    val is64Bit: Boolean,
    val sockets: Int,
    val physicalCores: Int,
    val logicalCores: Int,
    val totalLoadPercent: Double,
    val coreLoads: List<Double>,
    val coreFrequenciesGhz: List<Double>,
    val architecture: String,
    val temperatureCelsius: Double,
    val voltageVolts: Double
)

data class RamStick(
    val bankLabel: String,
    val capacityGb: Double,
    val clockSpeedMhz: Long,
    val memoryType: String,
    val manufacturer: String
)

data class MemorySnapshot(
    val totalGb: Double,
    val usedGb: Double,
    val availableGb: Double,
    val usagePercent: Double,
    val swapTotalGb: Double,
    val swapUsedGb: Double,
    val physicalSticks: List<RamStick>
)

data class DisplayInfo(
    val deviceName: String,
    val resolution: String,
    val refreshRateHz: Int,
    val bitDepth: Int,
    val isPrimary: Boolean
)

data class GpuSnapshot(
    val name: String,
    val vramMb: Long,
    val driverVersion: String,
    val deviceId: String
)

data class PartitionSnapshot(
    val driveLetter: String,
    val label: String,
    val fileSystem: String,
    val totalGb: Double,
    val freeGb: Double,
    val usedGb: Double,
    val usagePercent: Double
)

data class DiskSnapshot(
    val name: String,
    val model: String,
    val serial: String,
    val sizeGb: Double,
    val readBytesMb: Double,
    val writeBytesMb: Double,
    val partitions: List<String>
)

data class NetworkSnapshot(
    val displayName: String,
    val name: String,
    val ipv4Addresses: List<String>,
    val ipv6Addresses: List<String>,
    val macAddress: String,
    val gateway: String,
    val dnsServers: List<String>,
    val speedMbps: Long,
    val bytesReceivedMb: Double,
    val bytesSentMb: Double
)

data class SystemOverview(
    val osName: String,
    val osVersion: String,
    val osBuild: String,
    val osArch: String,
    val bootTime: String,
    val uptimeHours: Long,
    val motherboardManufacturer: String,
    val motherboardModel: String,
    val motherboardSerial: String,
    val biosManufacturer: String,
    val biosVersion: String,
    val biosDate: String
)

data class BatterySnapshot(
    val isPresent: Boolean,
    val remainingPercent: Double,
    val isCharging: Boolean,
    val estimatedTimeRemaining: String
)

data class PeripheralItem(
    val name: String,
    val vendor: String,
    val category: String
)

class HardwareScanner {
    private val systemInfo = SystemInfo()
    private val hardware = systemInfo.hardware
    private val os = systemInfo.operatingSystem
    private val processor = hardware.processor

    private var prevTicks = processor.systemCpuLoadTicks
    private var prevProcTicks = processor.processorCpuLoadTicks

    suspend fun getOverview(): SystemOverview = withContext(Dispatchers.IO) {
        val baseboard = hardware.computerSystem.baseboard
        val bios = hardware.computerSystem.firmware
        SystemOverview(
            osName = os.family,
            osVersion = os.versionInfo.version ?: "Windows",
            osBuild = os.versionInfo.buildNumber ?: "Unknown",
            osArch = System.getProperty("os.arch") ?: "x64",
            bootTime = java.time.Instant.ofEpochSecond(os.systemBootTime).toString().take(19).replace('T', ' '),
            uptimeHours = os.systemUptime / 3600,
            motherboardManufacturer = baseboard.manufacturer?.takeIf { it.isNotBlank() } ?: "Generic",
            motherboardModel = baseboard.model?.takeIf { it.isNotBlank() } ?: "Baseboard",
            motherboardSerial = baseboard.serialNumber?.takeIf { it.isNotBlank() } ?: "N/A",
            biosManufacturer = bios.manufacturer ?: "Generic",
            biosVersion = bios.version ?: "N/A",
            biosDate = bios.releaseDate?.takeIf { it.isNotBlank() } ?: "N/A"
        )
    }

    suspend fun getCpuSnapshot(): CpuSnapshot = withContext(Dispatchers.IO) {
        val totalLoad = processor.getSystemCpuLoadBetweenTicks(prevTicks) * 100.0
        prevTicks = processor.systemCpuLoadTicks

        val coreLoadArray = processor.getProcessorCpuLoadBetweenTicks(prevProcTicks)
        prevProcTicks = processor.processorCpuLoadTicks
        val coreLoads = coreLoadArray.map { (it * 100.0).coerceIn(0.0, 100.0) }

        val id = processor.processorIdentifier
        val freqs = processor.currentFreq.map { it / 1_000_000_000.0 }
        val sensors = hardware.sensors

        CpuSnapshot(
            model = id.name.trim(),
            vendor = id.vendor ?: "Unknown",
            family = id.family ?: "N/A",
            stepping = id.stepping ?: "N/A",
            processorId = id.processorID ?: "N/A",
            is64Bit = id.isCpu64bit,
            sockets = processor.physicalPackageCount.coerceAtLeast(1),
            physicalCores = processor.physicalProcessorCount,
            logicalCores = processor.logicalProcessorCount,
            totalLoadPercent = totalLoad.coerceIn(0.0, 100.0),
            coreLoads = coreLoads,
            coreFrequenciesGhz = freqs,
            architecture = id.microarchitecture ?: "x86_64",
            temperatureCelsius = sensors.cpuTemperature,
            voltageVolts = sensors.cpuVoltage
        )
    }

    suspend fun getMemorySnapshot(): MemorySnapshot = withContext(Dispatchers.IO) {
        val memory: GlobalMemory = hardware.memory
        val total = memory.total / (1024.0 * 1024.0 * 1024.0)
        val available = memory.available / (1024.0 * 1024.0 * 1024.0)
        val used = total - available
        val percent = (used / total) * 100.0

        val vm = memory.virtualMemory
        val swapTotal = vm.swapTotal / (1024.0 * 1024.0 * 1024.0)
        val swapUsed = vm.swapUsed / (1024.0 * 1024.0 * 1024.0)

        val sticks = memory.physicalMemory.map { pm: PhysicalMemory ->
            RamStick(
                bankLabel = pm.bankLabel ?: "Slot",
                capacityGb = pm.capacity / (1024.0 * 1024.0 * 1024.0),
                clockSpeedMhz = pm.clockSpeed / 1_000_000,
                memoryType = pm.memoryType ?: "DDR",
                manufacturer = pm.manufacturer ?: "Unknown"
            )
        }

        MemorySnapshot(
            totalGb = total,
            usedGb = used,
            availableGb = available,
            usagePercent = percent.coerceIn(0.0, 100.0),
            swapTotalGb = swapTotal,
            swapUsedGb = swapUsed,
            physicalSticks = sticks
        )
    }

    suspend fun getGpuSnapshots(): List<GpuSnapshot> = withContext(Dispatchers.IO) {
        hardware.graphicsCards.map { card: GraphicsCard ->
            GpuSnapshot(
                name = card.name ?: "Generic Display Adapter",
                vramMb = card.vRam / (1024 * 1024),
                driverVersion = card.versionInfo ?: "N/A",
                deviceId = card.deviceId ?: "N/A"
            )
        }
    }

    suspend fun getDisplaySnapshots(): List<DisplayInfo> = withContext(Dispatchers.IO) {
        try {
            val ge = GraphicsEnvironment.getLocalGraphicsEnvironment()
            ge.screenDevices.mapIndexed { index, dev ->
                val dm = dev.displayMode
                val refresh = if (dm.refreshRate > 0) dm.refreshRate else 60
                val bitDepth = if (dm.bitDepth > 0) dm.bitDepth else 32
                DisplayInfo(
                    deviceName = "Display  ()",
                    resolution = " x ",
                    refreshRateHz = refresh,
                    bitDepth = bitDepth,
                    isPrimary = index == 0
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    suspend fun getDiskSnapshots(): List<DiskSnapshot> = withContext(Dispatchers.IO) {
        hardware.diskStores.map { disk: HWDiskStore ->
            DiskSnapshot(
                name = disk.name,
                model = disk.model?.takeIf { it.isNotBlank() } ?: "Storage Drive",
                serial = disk.serial?.takeIf { it.isNotBlank() } ?: "N/A",
                sizeGb = disk.size / (1024.0 * 1024.0 * 1024.0),
                readBytesMb = disk.readBytes / (1024.0 * 1024.0),
                writeBytesMb = disk.writeBytes / (1024.0 * 1024.0),
                partitions = disk.partitions.map { it.mountPoint.ifBlank { it.name } }
            )
        }
    }

    suspend fun getPartitionSnapshots(): List<PartitionSnapshot> = withContext(Dispatchers.IO) {
        os.fileSystem.fileStores.map { fs: OSFileStore ->
            val total = fs.totalSpace / (1024.0 * 1024.0 * 1024.0)
            val free = fs.usableSpace / (1024.0 * 1024.0 * 1024.0)
            val used = (total - free).coerceAtLeast(0.0)
            val percent = if (total > 0) (used / total) * 100.0 else 0.0
            PartitionSnapshot(
                driveLetter = fs.mount ?: fs.name,
                label = fs.label.ifBlank { fs.name },
                fileSystem = fs.type ?: "NTFS",
                totalGb = total,
                freeGb = free,
                usedGb = used,
                usagePercent = percent.coerceIn(0.0, 100.0)
            )
        }
    }

    suspend fun getNetworkSnapshots(): List<NetworkSnapshot> = withContext(Dispatchers.IO) {
        val params = os.networkParams
        hardware.networkIFs
            .filter { it.iPv4addr.isNotEmpty() && it.iPv4addr.none { ip -> ip.startsWith("127.") } }
            .map { net: NetworkIF ->
                NetworkSnapshot(
                    displayName = net.displayName ?: net.name,
                    name = net.name,
                    ipv4Addresses = net.iPv4addr.toList(),
                    ipv6Addresses = net.iPv6addr.toList(),
                    macAddress = net.macaddr ?: "N/A",
                    gateway = params.ipv4DefaultGateway.ifBlank { "N/A" },
                    dnsServers = params.dnsServers.toList(),
                    speedMbps = net.speed / 1_000_000,
                    bytesReceivedMb = net.bytesRecv / (1024.0 * 1024.0),
                    bytesSentMb = net.bytesSent / (1024.0 * 1024.0)
                )
            }
    }

    suspend fun getBatterySnapshot(): BatterySnapshot = withContext(Dispatchers.IO) {
        val sources = hardware.powerSources
        if (sources.isEmpty()) {
            BatterySnapshot(isPresent = false, remainingPercent = 0.0, isCharging = false, estimatedTimeRemaining = "N/A")
        } else {
            val power = sources.first()
            val time = power.timeRemainingEstimated
            val timeStr = if (time > 0) "${time.toInt() / 60}m" else "Calculating..."
            BatterySnapshot(
                isPresent = true,
                remainingPercent = (power.remainingCapacityPercent * 100.0).coerceIn(0.0, 100.0),
                isCharging = power.isCharging,
                estimatedTimeRemaining = timeStr
            )
        }
    }

    suspend fun getPeripherals(): List<PeripheralItem> = withContext(Dispatchers.IO) {
        val items = mutableListOf<PeripheralItem>()
        hardware.soundCards.forEach { sc: SoundCard ->
            items.add(PeripheralItem(name = sc.name ?: "Audio Device", vendor = sc.codec ?: "Audio", category = "Sound / Audio"))
        }
        val usbList = hardware.getUsbDevices(false)
        usbList.forEach { usb: UsbDevice ->
            if (usb.name.isNotBlank() && !usb.name.contains("Root Hub", ignoreCase = true)) {
                items.add(PeripheralItem(name = usb.name, vendor = usb.vendor ?: "USB Device", category = "USB Peripheral"))
            }
        }
        items
    }
}