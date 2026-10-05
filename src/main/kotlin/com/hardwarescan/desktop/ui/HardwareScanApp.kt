package com.hardwarescan.desktop.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.*
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.hardwarescan.desktop.data.*
import com.hardwarescan.desktop.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive

enum class NavItem(val title: String, val icon: ImageVector) {
    DASHBOARD("Dashboard", Icons.Default.Dashboard),
    UPGRADES("Upgrade Path", Icons.AutoMirrored.Filled.TrendingUp),
    CPU("Processor", Icons.Default.Memory),
    MEMORY("Memory", Icons.Default.Storage),
    STORAGE("Storage", Icons.Default.Folder),
    GPU("Graphics", Icons.Default.Tv),
    NETWORK("Network", Icons.Default.Wifi),
    SYSTEM("System/BIOS", Icons.Default.Computer),
    PERIPHERALS("Peripherals", Icons.Default.Usb)
}

@Composable
fun HardwareScanApp(scanner: HardwareScanner) {
    var selectedNav by remember { mutableStateOf(NavItem.DASHBOARD) }

    var cpuInfo by remember { mutableStateOf<CpuSnapshot?>(null) }
    var memInfo by remember { mutableStateOf<MemorySnapshot?>(null) }
    var gpus by remember { mutableStateOf<List<GpuSnapshot>>(emptyList()) }
    var displays by remember { mutableStateOf<List<DisplayInfo>>(emptyList()) }
    var disks by remember { mutableStateOf<List<DiskSnapshot>>(emptyList()) }
    var partitions by remember { mutableStateOf<List<PartitionSnapshot>>(emptyList()) }
    var networks by remember { mutableStateOf<List<NetworkSnapshot>>(emptyList()) }
    var systemInfo by remember { mutableStateOf<SystemOverview?>(null) }
    var batteryInfo by remember { mutableStateOf<BatterySnapshot?>(null) }
    var peripherals by remember { mutableStateOf<List<PeripheralItem>>(emptyList()) }

    LaunchedEffect(Unit) {
        systemInfo = scanner.getOverview()
        gpus = scanner.getGpuSnapshots()
        displays = scanner.getDisplaySnapshots()
        disks = scanner.getDiskSnapshots()
        partitions = scanner.getPartitionSnapshots()
        networks = scanner.getNetworkSnapshots()
        batteryInfo = scanner.getBatterySnapshot()
        peripherals = scanner.getPeripherals()

        while (isActive) {
            cpuInfo = scanner.getCpuSnapshot()
            memInfo = scanner.getMemorySnapshot()
            delay(1000)
        }
    }

    Row(modifier = Modifier.fillMaxSize().background(DarkBackground)) {
        // Navigation Rail
        NavigationRail(
            containerColor = SurfaceDark,
            contentColor = TextPrimary,
            modifier = Modifier.fillMaxHeight().width(115.dp)
        ) {
            Spacer(modifier = Modifier.height(16.dp))
            Icon(Icons.Default.Speed, contentDescription = "Logo", tint = CyanAccent, modifier = Modifier.size(36.dp))
            Text(
                "Hardware\nScan",
                color = CyanAccent,
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(top = 4.dp, bottom = 20.dp)
            )

            NavItem.values().forEach { item ->
                NavigationRailItem(
                    selected = selectedNav == item,
                    onClick = { selectedNav = item },
                    icon = { Icon(item.icon, contentDescription = item.title) },
                    label = { Text(item.title, fontSize = 10.sp, fontWeight = FontWeight.Medium) },
                    colors = NavigationRailItemDefaults.colors(
                        selectedIconColor = CyanAccent,
                        selectedTextColor = CyanAccent,
                        indicatorColor = SurfaceDark.copy(alpha = 0.8f),
                        unselectedIconColor = TextSecondary,
                        unselectedTextColor = TextSecondary
                    )
                )
            }
        }

        // Main Content Area
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp)
        ) {
            when (selectedNav) {
                NavItem.DASHBOARD -> DashboardScreen(cpuInfo, memInfo, systemInfo, batteryInfo, gpus, partitions) {
                    selectedNav = NavItem.UPGRADES
                }
                NavItem.UPGRADES -> UpgradePathScreen(cpuInfo, memInfo, partitions, disks, systemInfo)
                NavItem.CPU -> CpuScreen(cpuInfo)
                NavItem.MEMORY -> MemoryScreen(memInfo)
                NavItem.STORAGE -> StorageScreen(partitions, disks)
                NavItem.GPU -> GpuScreen(gpus, displays)
                NavItem.NETWORK -> NetworkScreen(networks)
                NavItem.SYSTEM -> SystemScreen(systemInfo)
                NavItem.PERIPHERALS -> PeripheralsScreen(peripherals)
            }
        }
    }
}

@Composable
fun MetricCard(
    title: String,
    value: String,
    subtitle: String = "",
    progress: Float? = null,
    progressColor: Color = CyanAccent,
    icon: ImageVector? = null,
    modifier: Modifier = Modifier
) {
    Card(
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackground),
        modifier = modifier.border(1.dp, CardBorder, RoundedCornerShape(12.dp)).padding(4.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (icon != null) {
                    Icon(icon, contentDescription = null, tint = progressColor, modifier = Modifier.size(24.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                }
                Text(title, color = TextSecondary, fontSize = 13.sp, fontWeight = FontWeight.Medium)
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(value, color = TextPrimary, fontSize = 22.sp, fontWeight = FontWeight.Bold)
            if (subtitle.isNotEmpty()) {
                Text(subtitle, color = TextMuted, fontSize = 12.sp, maxLines = 1)
            }
            if (progress != null) {
                Spacer(modifier = Modifier.height(12.dp))
                LinearProgressIndicator(
                    progress = { progress.coerceIn(0f, 1f) },
                    modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)),
                    color = progressColor,
                    trackColor = DarkBackground
                )
            }
        }
    }
}

@Composable
fun DashboardScreen(
    cpu: CpuSnapshot?,
    mem: MemorySnapshot?,
    sys: SystemOverview?,
    battery: BatterySnapshot?,
    gpus: List<GpuSnapshot>,
    partitions: List<PartitionSnapshot>,
    onOpenUpgrades: () -> Unit
) {
    LazyColumn(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("PC Hardware Diagnostics", color = TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold)
                    Text("Real-time telemetry and component inspection", color = TextSecondary, fontSize = 14.sp)
                }
                Button(
                    onClick = onOpenUpgrades,
                    colors = ButtonDefaults.buttonColors(containerColor = CyanAccent, contentColor = DarkBackground),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Icon(Icons.AutoMirrored.Filled.TrendingUp, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Upgrade Path", fontWeight = FontWeight.Bold)
                }
            }
        }

        item {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                MetricCard(
                    title = "CPU Utilization",
                    value = "%",
                    subtitle = cpu?.model ?: "Scanning...",
                    progress = ((cpu?.totalLoadPercent ?: 0.0) / 100.0).toFloat(),
                    progressColor = CyanAccent,
                    icon = Icons.Default.Memory,
                    modifier = Modifier.weight(1f)
                )

                MetricCard(
                    title = "RAM Usage",
                    value = "%",
                    subtitle = " /  GB",
                    progress = ((mem?.usagePercent ?: 0.0) / 100.0).toFloat(),
                    progressColor = BlueAccent,
                    icon = Icons.Default.Storage,
                    modifier = Modifier.weight(1f)
                )

                val primaryDrive = partitions.firstOrNull()
                MetricCard(
                    title = "Primary Storage ()",
                    value = "%",
                    subtitle = " GB free of  GB",
                    progress = ((primaryDrive?.usagePercent ?: 0.0) / 100.0).toFloat(),
                    progressColor = OrangeAccent,
                    icon = Icons.Default.Folder,
                    modifier = Modifier.weight(1f)
                )

                if (battery?.isPresent == true) {
                    MetricCard(
                        title = "Battery",
                        value = "%",
                        subtitle = if (battery.isCharging) "Charging (AC)" else "On Battery ()",
                        progress = (battery.remainingPercent / 100.0).toFloat(),
                        progressColor = GreenAccent,
                        icon = Icons.Default.BatteryChargingFull,
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }

        item {
            Card(
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = CardBackground),
                modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
            ) {
                Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("System Summary", color = TextPrimary, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    HorizontalDivider(color = CardBorder)
                    InfoRow("Operating System", " () - ")
                    InfoRow("Motherboard", " - ")
                    InfoRow("Primary Graphics", gpus.firstOrNull()?.name ?: "N/A")
                    InfoRow("BIOS Version", sys?.biosVersion ?: "N/A")
                    InfoRow("System Boot Time", sys?.bootTime ?: "N/A")
                    InfoRow("Uptime", " Hours")
                }
            }
        }
    }
}

@Composable
fun CpuScreen(cpu: CpuSnapshot?) {
    LazyColumn(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Text("Central Processing Unit (CPU)", color = TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold)
            Text(cpu?.model ?: "Scanning...", color = CyanAccent, fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
        }

        item {
            Card(
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = CardBackground),
                modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
            ) {
                Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("Processor Specifications", color = TextPrimary, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    HorizontalDivider(color = CardBorder)
                    InfoRow("Manufacturer / Vendor", cpu?.vendor ?: "N/A")
                    InfoRow("Microarchitecture", cpu?.architecture ?: "x86_64")
                    InfoRow("Physical Sockets", "")
                    InfoRow("Physical Cores", "")
                    InfoRow("Logical Processors (Threads)", "")
                    InfoRow("CPU Family / Stepping", "Family , Stepping ")
                    InfoRow("Processor ID", cpu?.processorId ?: "N/A")
                    InfoRow("64-Bit Instruction Set", if (cpu?.is64Bit == true) "Yes (64-Bit)" else "No")
                    if (cpu != null && cpu.temperatureCelsius > 0) {
                        InfoRow("CPU Temperature", " °C")
                    }
                    if (cpu != null && cpu.voltageVolts > 0) {
                        InfoRow("CPU Core Voltage", " V")
                    }
                }
            }
        }

        // Per-Core Real-time Load
        if (cpu != null && cpu.coreLoads.isNotEmpty()) {
            item {
                Text("Per-Core Real-Time Utilization", color = TextPrimary, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            }
            item {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    cpu.coreLoads.chunked(4).forEachIndexed { rowIndex, rowCores ->
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            rowCores.forEachIndexed { colIndex, load ->
                                val coreIndex = rowIndex * 4 + colIndex
                                val freq = cpu.coreFrequenciesGhz.getOrNull(coreIndex)
                                Card(
                                    shape = RoundedCornerShape(8.dp),
                                    colors = CardDefaults.cardColors(containerColor = CardBackground),
                                    modifier = Modifier.weight(1f).border(1.dp, CardBorder, RoundedCornerShape(8.dp)).padding(2.dp)
                                ) {
                                    Column(modifier = Modifier.padding(12.dp)) {
                                        Text("Core ", color = TextSecondary, fontSize = 12.sp, fontWeight = FontWeight.Medium)
                                        Text("%", color = TextPrimary, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                                        if (freq != null && freq > 0) {
                                            Text(" GHz", color = TextMuted, fontSize = 11.sp)
                                        }
                                        Spacer(modifier = Modifier.height(6.dp))
                                        LinearProgressIndicator(
                                            progress = { (load / 100.0).toFloat().coerceIn(0f, 1f) },
                                            modifier = Modifier.fillMaxWidth().height(4.dp).clip(RoundedCornerShape(2.dp)),
                                            color = if (load > 80) RedAccent else CyanAccent,
                                            trackColor = DarkBackground
                                        )
                                    }
                                }
                            }
                            // Fill empty slots if last row has fewer than 4 cores
                            for (i in rowCores.size until 4) {
                                Spacer(modifier = Modifier.weight(1f))
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun MemoryScreen(mem: MemorySnapshot?) {
    LazyColumn(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Text("Memory & RAM Architecture", color = TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold)
        }

        item {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                MetricCard("Physical RAM Installed", " GB", "Total Hardware Memory", null, CyanAccent, Icons.Default.Memory, Modifier.weight(1f))
                MetricCard("RAM In Use", " GB", "% utilized", ((mem?.usagePercent ?: 0.0) / 100.0).toFloat(), BlueAccent, Icons.Default.Storage, Modifier.weight(1f))
                MetricCard("Available Memory", " GB", "Ready for allocation", null, GreenAccent, Icons.Default.CheckCircle, Modifier.weight(1f))
                MetricCard("Virtual Memory / Swap", " GB", " GB committed", null, PurpleAccent, Icons.Default.Folder, Modifier.weight(1f))
            }
        }

        item {
            Text("Physical Memory Banks & Slots (DIMMs)", color = TextPrimary, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        }

        if (mem != null && mem.physicalSticks.isNotEmpty()) {
            items(mem.physicalSticks) { stick ->
                Card(
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = CardBackground),
                    modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
                ) {
                    Column(modifier = Modifier.padding(18.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text(stick.bankLabel, color = CyanAccent, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                            Text(" GB ", color = TextPrimary, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                        }
                        HorizontalDivider(color = CardBorder)
                        InfoRow("Manufacturer", stick.manufacturer)
                        InfoRow("Clock Speed / Frequency", " MHz (MT/s)")
                        InfoRow("Memory Type", stick.memoryType)
                    }
                }
            }
        } else {
            item {
                Card(
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = CardBackground),
                    modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
                ) {
                    Text("Bank telemetry not exposed by virtualized environment.", color = TextSecondary, modifier = Modifier.padding(20.dp))
                }
            }
        }
    }
}

@Composable
fun StorageScreen(partitions: List<PartitionSnapshot>, disks: List<DiskSnapshot>) {
    LazyColumn(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Text("Logical Drives & Partitions", color = TextPrimary, fontSize = 24.sp, fontWeight = FontWeight.Bold)
        }

        items(partitions) { part ->
            Card(
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = CardBackground),
                modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
            ) {
                Column(modifier = Modifier.padding(18.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text(" []", color = CyanAccent, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                        Text("% Used", color = if (part.usagePercent > 85) RedAccent else TextPrimary, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                    }
                    LinearProgressIndicator(
                        progress = { (part.usagePercent / 100.0).toFloat().coerceIn(0f, 1f) },
                        modifier = Modifier.fillMaxWidth().height(8.dp).clip(RoundedCornerShape(4.dp)),
                        color = if (part.usagePercent > 85) RedAccent else CyanAccent,
                        trackColor = DarkBackground
                    )
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Used:  GB", color = TextSecondary, fontSize = 13.sp)
                        Text("Free:  GB", color = GreenAccent, fontSize = 13.sp)
                        Text("Total:  GB ()", color = TextSecondary, fontSize = 13.sp)
                    }
                }
            }
        }

        item {
            Text("Physical Storage Devices", color = TextPrimary, fontSize = 24.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 8.dp))
        }

        items(disks) { disk ->
            Card(
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = CardBackground),
                modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
            ) {
                Column(modifier = Modifier.padding(18.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(disk.model, color = TextPrimary, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                    HorizontalDivider(color = CardBorder)
                    InfoRow("Device Identifier", disk.name)
                    InfoRow("Serial Number", disk.serial)
                    InfoRow("Raw Disk Capacity", " GB")
                    InfoRow("Total Lifetime Reads", " MB")
                    InfoRow("Total Lifetime Writes", " MB")
                }
            }
        }
    }
}

@Composable
fun GpuScreen(gpus: List<GpuSnapshot>, displays: List<DisplayInfo>) {
    LazyColumn(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Text("Graphics Processing Units (GPU)", color = TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold)
        }

        items(gpus) { gpu ->
            Card(
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = CardBackground),
                modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
            ) {
                Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text(gpu.name, color = CyanAccent, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                    HorizontalDivider(color = CardBorder)
                    InfoRow("Dedicated Video Memory (VRAM)", if (gpu.vramMb > 0) " MB ( GB)" else "Shared / Dynamic Memory")
                    InfoRow("Driver Version", gpu.driverVersion)
                    InfoRow("Device ID", gpu.deviceId)
                }
            }
        }

        item {
            Text("Connected Displays & Monitors", color = TextPrimary, fontSize = 24.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 10.dp))
        }

        items(displays) { disp ->
            Card(
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = CardBackground),
                modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
            ) {
                Column(modifier = Modifier.padding(18.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text(disp.deviceName, color = TextPrimary, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                        if (disp.isPrimary) {
                            Text("PRIMARY MONITOR", color = GreenAccent, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                    HorizontalDivider(color = CardBorder)
                    InfoRow("Active Screen Resolution", disp.resolution)
                    InfoRow("Refresh Rate", " Hz")
                    InfoRow("Color Depth", "-bit")
                }
            }
        }
    }
}

@Composable
fun NetworkScreen(networks: List<NetworkSnapshot>) {
    LazyColumn(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Text("Network Adapters & Connectivity", color = TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold)
        }

        items(networks) { net ->
            Card(
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = CardBackground),
                modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
            ) {
                Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text(net.displayName, color = CyanAccent, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    HorizontalDivider(color = CardBorder)
                    InfoRow("IPv4 Address", net.ipv4Addresses.joinToString(", "))
                    if (net.ipv6Addresses.isNotEmpty()) {
                        InfoRow("IPv6 Address", net.ipv6Addresses.first())
                    }
                    InfoRow("MAC Address (Physical)", net.macAddress)
                    InfoRow("Default Gateway", net.gateway)
                    if (net.dnsServers.isNotEmpty()) {
                        InfoRow("DNS Servers", net.dnsServers.joinToString(", "))
                    }
                    InfoRow("Max Link Speed", if (net.speedMbps > 0) " Mbps ( Gbps)" else "Dynamic")
                    InfoRow("Data Received", " MB")
                    InfoRow("Data Sent", " MB")
                }
            }
        }
    }
}

@Composable
fun SystemScreen(sys: SystemOverview?) {
    LazyColumn(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Text("System & Motherboard Architecture", color = TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold)
        }

        item {
            Card(
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = CardBackground),
                modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
            ) {
                Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("Motherboard & BIOS", color = CyanAccent, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    HorizontalDivider(color = CardBorder)
                    InfoRow("Motherboard Manufacturer", sys?.motherboardManufacturer ?: "N/A")
                    InfoRow("Motherboard Model", sys?.motherboardModel ?: "N/A")
                    InfoRow("Motherboard Serial Number", sys?.motherboardSerial ?: "N/A")
                    InfoRow("BIOS Vendor", sys?.biosManufacturer ?: "N/A")
                    InfoRow("BIOS Version", sys?.biosVersion ?: "N/A")
                    InfoRow("BIOS Release Date", sys?.biosDate ?: "N/A")
                }
            }
        }

        item {
            Card(
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = CardBackground),
                modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
            ) {
                Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("Operating System Details", color = BlueAccent, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    HorizontalDivider(color = CardBorder)
                    InfoRow("OS Distribution", sys?.osName ?: "Windows")
                    InfoRow("Version", sys?.osVersion ?: "N/A")
                    InfoRow("Build Number", sys?.osBuild ?: "N/A")
                    InfoRow("Kernel Architecture", sys?.osArch ?: "x64")
                    InfoRow("System Boot Timestamp", sys?.bootTime ?: "N/A")
                    InfoRow("Active Uptime", " Hours")
                }
            }
        }
    }
}

@Composable
fun PeripheralsScreen(peripherals: List<PeripheralItem>) {
    LazyColumn(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Text("Connected Peripherals & Devices", color = TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold)
            Text("USB peripherals, Audio controllers, and Sound endpoints", color = TextSecondary, fontSize = 14.sp)
        }

        if (peripherals.isNotEmpty()) {
            items(peripherals) { item ->
                Card(
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = CardBackground),
                    modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(item.name, color = TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                            Text(item.vendor, color = TextSecondary, fontSize = 13.sp)
                        }
                        Text(item.category, color = CyanAccent, fontSize = 12.sp, fontWeight = FontWeight.Medium)
                    }
                }
            }
        } else {
            item {
                Card(
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = CardBackground),
                    modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
                ) {
                    Text("No external USB or audio peripherals reported.", color = TextSecondary, modifier = Modifier.padding(20.dp))
                }
            }
        }
    }
}

@Composable
fun InfoRow(label: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(label, color = TextSecondary, fontSize = 14.sp)
        Text(value, color = TextPrimary, fontSize = 14.sp, fontWeight = FontWeight.Medium)
    }
}