package com.hardwarescan.desktop.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.hardwarescan.desktop.data.*
import com.hardwarescan.desktop.theme.*

@Composable
fun UpgradePathScreen(
    cpu: CpuSnapshot?,
    mem: MemorySnapshot?,
    partitions: List<PartitionSnapshot>,
    disks: List<DiskSnapshot>,
    sys: SystemOverview?
) {
    val memUpgrade = remember(mem, sys) { UpgradeAdvisor.evaluateMemory(mem, sys) }
    val cpuUpgrade = remember(cpu, sys) { UpgradeAdvisor.evaluateCpu(cpu, sys) }
    val storageUpgrade = remember(partitions, disks) { UpgradeAdvisor.evaluateStorage(partitions, disks) }

    LazyColumn(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Text("Hardware Upgrade Path", color = TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.Bold)
            Text("Intelligent hardware evaluation for Memory, Processor, and Storage drives", color = TextSecondary, fontSize = 14.sp)
        }

        // Summary Banner
        item {
            Card(
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceDark),
                modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
            ) {
                Row(
                    modifier = Modifier.padding(20.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(Icons.Default.AutoAwesome, contentDescription = null, tint = CyanAccent, modifier = Modifier.size(36.dp))
                    Spacer(modifier = Modifier.width(16.dp))
                    Column {
                        Text("System Upgrade Intelligence", color = TextPrimary, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                        Text(
                            "Analyzing component compatibility, memory channel topology, platform sockets, and storage interface bottlenecks.",
                            color = TextSecondary,
                            fontSize = 13.sp
                        )
                    }
                }
            }
        }

        // 1. Memory Upgrade Path Card
        item {
            UpgradeCard(
                icon = Icons.Default.Storage,
                recommendation = memUpgrade
            )
        }

        // 2. CPU Upgrade Path Card
        item {
            UpgradeCard(
                icon = Icons.Default.Memory,
                recommendation = cpuUpgrade
            )
        }

        // 3. Storage Upgrade Path Card
        item {
            UpgradeCard(
                icon = Icons.Default.Folder,
                recommendation = storageUpgrade
            )
        }
    }
}

@Composable
fun UpgradeCard(
    icon: ImageVector,
    recommendation: UpgradeRecommendation
) {
    val badgeColor = when (recommendation.status) {
        UpgradeStatus.CRITICAL_UPGRADE -> RedAccent
        UpgradeStatus.RECOMMENDED -> OrangeAccent
        UpgradeStatus.OPTIONAL -> BlueAccent
        UpgradeStatus.OPTIMAL -> GreenAccent
    }

    val badgeText = when (recommendation.status) {
        UpgradeStatus.CRITICAL_UPGRADE -> "CRITICAL UPGRADE"
        UpgradeStatus.RECOMMENDED -> "RECOMMENDED UPGRADE"
        UpgradeStatus.OPTIONAL -> "OPTIONAL / EXPANSION"
        UpgradeStatus.OPTIMAL -> "OPTIMAL HARDWARE"
    }

    Card(
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackground),
        modifier = Modifier.fillMaxWidth().border(1.dp, CardBorder, RoundedCornerShape(12.dp))
    ) {
        Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            // Header Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(icon, contentDescription = null, tint = CyanAccent, modifier = Modifier.size(24.dp))
                    Spacer(modifier = Modifier.width(10.dp))
                    Text(recommendation.category, color = TextPrimary, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                }
                Surface(
                    shape = RoundedCornerShape(6.dp),
                    color = badgeColor.copy(alpha = 0.15f),
                    border = BorderStroke(1.dp, badgeColor.copy(alpha = 0.5f))
                ) {
                    Text(
                        badgeText,
                        color = badgeColor,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                    )
                }
            }

            HorizontalDivider(color = CardBorder)

            // Headline & Hardware
            Text(recommendation.headline, color = CyanAccent, fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
            InfoRow("Current Detected Hardware", recommendation.currentHardware)

            // Recommendation Box
            Card(
                shape = RoundedCornerShape(8.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceDark),
                modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp)
            ) {
                Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("RECOMMENDED UPGRADE PATH:", color = TextSecondary, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    Text(recommendation.recommendedAction, color = TextPrimary, fontSize = 14.sp, fontWeight = FontWeight.Medium)
                    Spacer(modifier = Modifier.height(4.dp))
                    Text("EXPECTED PERFORMANCE GAIN:", color = TextSecondary, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    Text(recommendation.expectedImpact, color = GreenAccent, fontSize = 13.sp, fontWeight = FontWeight.Medium)
                }
            }

            // Technical Details List
            if (recommendation.technicalDetails.isNotEmpty()) {
                Text("Technical & Compatibility Details:", color = TextSecondary, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    recommendation.technicalDetails.forEach { detail ->
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text("• ", color = CyanAccent, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                            Text(detail, color = TextPrimary, fontSize = 13.sp)
                        }
                    }
                }
            }
        }
    }
}