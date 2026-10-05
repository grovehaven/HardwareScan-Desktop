package com.hardwarescan.desktop.data

enum class UpgradeStatus {
    CRITICAL_UPGRADE,
    RECOMMENDED,
    OPTIONAL,
    OPTIMAL
}

data class UpgradeRecommendation(
    val category: String,
    val currentHardware: String,
    val status: UpgradeStatus,
    val headline: String,
    val recommendedAction: String,
    val expectedImpact: String,
    val technicalDetails: List<String>
)

object UpgradeAdvisor {

    fun evaluateMemory(mem: MemorySnapshot?, sys: SystemOverview?): UpgradeRecommendation {
        if (mem == null) {
            return UpgradeRecommendation(
                category = "Memory (RAM)",
                currentHardware = "Scanning...",
                status = UpgradeStatus.OPTIONAL,
                headline = "Memory Telemetry Required",
                recommendedAction = "Inspect memory specifications.",
                expectedImpact = "N/A",
                technicalDetails = emptyList()
            )
        }

        val totalGb = mem.totalGb
        val sticks = mem.physicalSticks
        val stickCount = sticks.size
        val ddrType = sticks.firstOrNull()?.memoryType ?: "DDR"
        val speed = sticks.firstOrNull()?.clockSpeedMhz ?: 0

        val details = mutableListOf<String>()
        details.add("Total Installed:  GB ( populated slot)")
        if (speed > 0) details.add("Memory Frequency:  MHz (MT/s) []")
        details.add("Virtual Memory / Swap:  GB")

        val isMobile = sys?.osName?.contains("laptop", ignoreCase = true) == true ||
                sys?.motherboardModel?.contains("laptop", ignoreCase = true) == true ||
                sys?.motherboardModel?.contains("notebook", ignoreCase = true) == true

        details.add("Form Factor: " + if (isMobile) "SO-DIMM (Laptop)" else "288-pin DIMM (Desktop)")

        return when {
            totalGb < 12.0 -> {
                UpgradeRecommendation(
                    category = "Memory (RAM)",
                    currentHardware = " GB ",
                    status = UpgradeStatus.CRITICAL_UPGRADE,
                    headline = "Severe Multi-Tasking Bottleneck",
                    recommendedAction = "Upgrade to at least 16 GB or 32 GB. 8 GB or less is heavily consumed by Windows 11 and web browsers, causing pagefile thrashing.",
                    expectedImpact = "Huge: Eliminates system stuttering, browser tab reloads, and application freeze-ups.",
                    technicalDetails = details + listOf("Recommended Kit: 2x 8GB or 2x 16GB matching dual-channel kit")
                )
            }
            stickCount == 1 -> {
                UpgradeRecommendation(
                    category = "Memory (RAM)",
                    currentHardware = " GB  (Single Stick)",
                    status = UpgradeStatus.RECOMMENDED,
                    headline = "Single-Channel Bandwidth Bottleneck",
                    recommendedAction = "Add a second matching  GB  module to enable Dual-Channel mode.",
                    expectedImpact = "Significant: Doubles memory bus bandwidth; delivers 10% to 25% higher CPU frame rates in games and heavy computations.",
                    technicalDetails = details + listOf("Configuration: Single-Channel (64-bit bus) -> Upgrade to Dual-Channel (128-bit bus)")
                )
            }
            totalGb in 12.0..20.0 -> {
                UpgradeRecommendation(
                    category = "Memory (RAM)",
                    currentHardware = " GB  (Dual Channel)",
                    status = UpgradeStatus.OPTIONAL,
                    headline = "Adequate for Standard Workloads",
                    recommendedAction = "16 GB is optimal for everyday use and esports gaming. If you do 4K video editing, heavy CAD/3D rendering, or run virtual machines/local AI, upgrade to 32 GB or 64 GB.",
                    expectedImpact = "Moderate: Future-proofs system for next-gen AAA titles and heavy creative workflows.",
                    technicalDetails = details + listOf("Dual-Channel is active", "Suggested Target: 32 GB (2x 16GB)")
                )
            }
            totalGb in 24.0..36.0 -> {
                UpgradeRecommendation(
                    category = "Memory (RAM)",
                    currentHardware = " GB ",
                    status = UpgradeStatus.OPTIMAL,
                    headline = "High-Performance Sweet Spot",
                    recommendedAction = "Your 32 GB capacity is ideal for virtually all gaming and professional desktop workloads. No upgrade needed.",
                    expectedImpact = "Peak performance already achieved for current platform.",
                    technicalDetails = details + listOf("Dual-channel bandwidth optimized", "Sufficient headroom for heavy multitasking")
                )
            }
            else -> {
                UpgradeRecommendation(
                    category = "Memory (RAM)",
                    currentHardware = " GB ",
                    status = UpgradeStatus.OPTIMAL,
                    headline = "Workstation / Enthusiast Capacity",
                    recommendedAction = "64 GB+ installed. Memory capacity is maxed out for high-end professional production.",
                    expectedImpact = "Maximal capacity.",
                    technicalDetails = details
                )
            }
        }
    }

    fun evaluateCpu(cpu: CpuSnapshot?, sys: SystemOverview?): UpgradeRecommendation {
        if (cpu == null) {
            return UpgradeRecommendation(
                category = "Processor (CPU)",
                currentHardware = "Scanning...",
                status = UpgradeStatus.OPTIONAL,
                headline = "CPU Telemetry Required",
                recommendedAction = "Inspect processor specifications.",
                expectedImpact = "N/A",
                technicalDetails = emptyList()
            )
        }

        val model = cpu.model
        val cores = cpu.physicalCores
        val threads = cpu.logicalCores
        val arch = cpu.architecture

        val details = mutableListOf<String>()
        details.add("Architecture:  ( Cores /  Threads)")
        details.add("Vendor: ")
        details.add("Family / Stepping:  (Stepping )")

        // Detect mobile/laptop CPUs (BGA soldered)
        val isMobileCpu = model.matches(Regex(".*\\b(H|HX|U|G|Y|HS|HQ|HK)\\b.*", RegexOption.IGNORE_CASE)) ||
                model.contains("Mobile", ignoreCase = true) ||
                sys?.motherboardModel?.contains("laptop", ignoreCase = true) == true ||
                sys?.motherboardManufacturer?.contains("Dell", ignoreCase = true) == true && sys.motherboardModel.contains("0", ignoreCase = true)

        if (isMobileCpu) {
            details.add("Socket Type: BGA (Ball Grid Array - Soldered directly to Motherboard)")
            return UpgradeRecommendation(
                category = "Processor (CPU)",
                currentHardware = model,
                status = UpgradeStatus.OPTIONAL,
                headline = "Soldered Mobile Processor (Non-Replaceable)",
                recommendedAction = "This processor is permanently soldered onto the laptop/mini-PC motherboard and cannot be physically replaced. To boost system speed, prioritize upgrading RAM (to 32GB) and storage to a high-speed NVMe SSD.",
                expectedImpact = "Physical CPU upgrade is not possible; system replacement required for higher tier CPU compute.",
                technicalDetails = details + listOf("Thermal limits dictate performance; ensure cooling vents and thermal paste are maintained.")
            )
        }

        // Desktop socket analysis
        return when {
            // AMD AM4 Platform
            model.contains("Ryzen", ignoreCase = true) && (model.contains("1", ignoreCase = true) || model.contains("2", ignoreCase = true) || model.contains("3", ignoreCase = true) || model.contains("4", ignoreCase = true) || model.contains("5", ignoreCase = true)) && !model.contains("7000") && !model.contains("8000") && !model.contains("9000") -> {
                details.add("Platform Socket: AMD Socket AM4")
                details.add("Supported CPUs: Ryzen 1000 through Ryzen 5000 Series (DDR4)")
                if (model.contains("X3D", ignoreCase = true) || model.contains("5900X") || model.contains("5950X") || model.contains("5800X")) {
                    UpgradeRecommendation(
                        category = "Processor (CPU)",
                        currentHardware = model,
                        status = UpgradeStatus.OPTIMAL,
                        headline = "Peak AM4 Platform Performance",
                        recommendedAction = "You are already on the top tier of Socket AM4. Next major CPU upgrade requires transitioning to Socket AM5 (Ryzen 7000/9000 + DDR5 + AM5 motherboard).",
                        expectedImpact = "Optimal for AM4 platform.",
                        technicalDetails = details
                    )
                } else {
                    UpgradeRecommendation(
                        category = "Processor (CPU)",
                        currentHardware = model,
                        status = UpgradeStatus.RECOMMENDED,
                        headline = "AM4 In-Socket Upgrade Available",
                        recommendedAction = "Upgrade to Ryzen 7 5700X3D or 5800X3D for an exceptional gaming performance boost, or Ryzen 9 5900X (12-Core) for heavy productivity. Compatible with existing motherboard after a simple BIOS update.",
                        expectedImpact = "High: 3D V-Cache delivers up to 30-50% higher gaming 1% low framerates without replacing motherboard or RAM.",
                        technicalDetails = details + listOf("Prerequisite: Update motherboard BIOS to latest version before removing current CPU.")
                    )
                }
            }

            // AMD AM5 Platform
            model.contains("Ryzen", ignoreCase = true) && (model.contains("7000") || model.contains("8000") || model.contains("9000")) -> {
                details.add("Platform Socket: AMD Socket AM5 (DDR5)")
                UpgradeRecommendation(
                    category = "Processor (CPU)",
                    currentHardware = model,
                    status = if (model.contains("X3D")) UpgradeStatus.OPTIMAL else UpgradeStatus.OPTIONAL,
                    headline = "Modern AM5 Ecosystem",
                    recommendedAction = if (model.contains("X3D")) "Top-of-the-line gaming processor installed. Socket AM5 is supported through 2027+ for future drop-in upgrades."
                    else "Drop-in upgrade path available to Ryzen 7 7800X3D / 9800X3D for maximum gaming, or Ryzen 9 9950X for 16-core workstation compute.",
                    expectedImpact = "High efficiency and sustained architectural roadmap.",
                    technicalDetails = details + listOf("Native PCIe 5.0 and DDR5 support")
                )
            }

            // Intel LGA 1700 (12th, 13th, 14th Gen)
            model.contains("i3-12") || model.contains("i5-12") || model.contains("i5-13") || model.contains("i5-14") || model.contains("i7-12") -> {
                details.add("Platform Socket: Intel LGA 1700")
                details.add("Supports: Intel 12th, 13th, and 14th Gen Core Processors")
                UpgradeRecommendation(
                    category = "Processor (CPU)",
                    currentHardware = model,
                    status = UpgradeStatus.RECOMMENDED,
                    headline = "LGA 1700 In-Socket Upgrade Path",
                    recommendedAction = "Upgrade in-socket to Core i7-13700K / 14700K (20 threads) or Core i9-14900K (24 cores / 32 threads) for massive multi-core gains without buying a new motherboard.",
                    expectedImpact = "High: Doubled thread count and higher boost frequencies for gaming and rendering.",
                    technicalDetails = details + listOf("Ensure motherboard power delivery (VRM) and cooling (240mm+ AIO) are adequate for i7/i9 K-SKUs.")
                )
            }

            // Intel Core i7/i9 13th/14th Gen Top-Tier
            model.contains("13700") || model.contains("13900") || model.contains("14700") || model.contains("14900") -> {
                details.add("Platform Socket: Intel LGA 1700")
                UpgradeRecommendation(
                    category = "Processor (CPU)",
                    currentHardware = model,
                    status = UpgradeStatus.OPTIMAL,
                    headline = "High-End Desktop Compute",
                    recommendedAction = "Processor performance is at the top of the LGA 1700 generation. Next generation upgrade will require an LGA 1851 motherboard.",
                    expectedImpact = "Maximum current generation performance.",
                    technicalDetails = details
                )
            }

            // Older Quad-Core or Low Core Count
            cores <= 4 -> {
                details.add("Configuration:  Physical Cores")
                UpgradeRecommendation(
                    category = "Processor (CPU)",
                    currentHardware = model,
                    status = UpgradeStatus.CRITICAL_UPGRADE,
                    headline = "Legacy 4-Core Bottleneck",
                    recommendedAction = "Modern Windows 11 and current software expect 6 to 8 physical cores minimum. Upgrading to a 6-core / 12-thread or 8-core / 16-thread modern platform will dramatically improve responsiveness.",
                    expectedImpact = "Transformative: Drastically reduces 100% CPU spikes, hitching, and background multitasking lag.",
                    technicalDetails = details
                )
            }

            else -> {
                UpgradeRecommendation(
                    category = "Processor (CPU)",
                    currentHardware = model,
                    status = UpgradeStatus.OPTIONAL,
                    headline = "Solid Core Foundation",
                    recommendedAction = " Cores /  Threads provides good capability. Monitor CPU utilization under your heaviest workflows before deciding on an in-socket upgrade.",
                    expectedImpact = "Moderate gains depending on software workload.",
                    technicalDetails = details
                )
            }
        }
    }

    fun evaluateStorage(partitions: List<PartitionSnapshot>, disks: List<DiskSnapshot>): UpgradeRecommendation {
        if (partitions.isEmpty() && disks.isEmpty()) {
            return UpgradeRecommendation(
                category = "Hard Drives & Storage",
                currentHardware = "Scanning...",
                status = UpgradeStatus.OPTIONAL,
                headline = "Storage Telemetry Required",
                recommendedAction = "Inspect storage devices.",
                expectedImpact = "N/A",
                technicalDetails = emptyList()
            )
        }

        val primaryPartition = partitions.firstOrNull { it.driveLetter.startsWith("C", ignoreCase = true) } ?: partitions.firstOrNull()
        val primaryDisk = disks.firstOrNull()
        val totalCapacityGb = disks.sumOf { it.sizeGb }
        val diskModel = primaryDisk?.model ?: "Storage Drive"

        val details = mutableListOf<String>()
        details.add("Primary Drive Model: ")
        details.add("Total Installed Storage:  GB across  physical drive(s)")
        partitions.forEach { part ->
            details.add("Partition :  /  GB used (%)")
        }

        val isHdd = diskModel.contains("HDD", ignoreCase = true) ||
                diskModel.contains("WDC WD", ignoreCase = true) && !diskModel.contains("SSD", ignoreCase = true) ||
                diskModel.contains("ST1000", ignoreCase = true) || diskModel.contains("ST2000", ignoreCase = true) ||
                diskModel.contains("BarraCuda", ignoreCase = true)

        val isNvme = diskModel.contains("NVMe", ignoreCase = true) ||
                diskModel.contains("Samsung SSD 9", ignoreCase = true) ||
                diskModel.contains("Crucial P", ignoreCase = true) ||
                diskModel.contains("WD_BLACK", ignoreCase = true) ||
                diskModel.contains("SN7", ignoreCase = true) || diskModel.contains("SN8", ignoreCase = true)

        val highUsagePartition = partitions.firstOrNull { it.usagePercent >= 85.0 }

        return when {
            isHdd -> {
                UpgradeRecommendation(
                    category = "Hard Drives & Storage",
                    currentHardware = " (Mechanical HDD)",
                    status = UpgradeStatus.CRITICAL_UPGRADE,
                    headline = "Mechanical Hard Drive Boot Bottleneck",
                    recommendedAction = "URGENT UPGRADE: Your primary drive is a mechanical spinning hard drive (HDD). Upgrading to an M.2 NVMe PCIe SSD or 2.5\" SATA SSD is the single biggest performance upgrade you can make to a computer.",
                    expectedImpact = "Massive: 10x to 20x faster boot times (under 15 seconds), instant app opening, and zero disk lag.",
                    technicalDetails = details + listOf("Recommended: 1TB or 2TB M.2 NVMe Gen 4 SSD (e.g. WD Black SN850X, Samsung 990 Pro, Crucial P3 Plus)")
                )
            }
            highUsagePartition != null -> {
                UpgradeRecommendation(
                    category = "Hard Drives & Storage",
                    currentHardware = " (% Full)",
                    status = UpgradeStatus.RECOMMENDED,
                    headline = "Storage Capacity Warning (>85% Full)",
                    recommendedAction = "Drive  is % full. Solid state drives experience degradation in write speed and flash endurance when filled past 80-85%. Add a secondary 1TB/2TB NVMe or SATA SSD for your game library and files.",
                    expectedImpact = "High: Prevents severe SSD thermal write-throttling and restores peak sustained IOPS speeds.",
                    technicalDetails = details + listOf("Free space remaining on :  GB", "Action: Add secondary internal M.2 SSD or 2TB external SSD")
                )
            }
            !isNvme -> {
                UpgradeRecommendation(
                    category = "Hard Drives & Storage",
                    currentHardware = " (SATA SSD)",
                    status = UpgradeStatus.RECOMMENDED,
                    headline = "SATA to M.2 NVMe PCIe Upgrade Available",
                    recommendedAction = "Your system is operating on a SATA-based SSD (~500 MB/s). If your motherboard has an M.2 PCIe slot, upgrading to a PCIe Gen 4 NVMe SSD (~5,000 to 7,400 MB/s) delivers 10x-14x higher sequential bandwidth.",
                    expectedImpact = "Moderate to High: Faster game loading times with DirectStorage support and quicker 4K video scrubbing.",
                    technicalDetails = details + listOf("SATA III ceiling: ~550 MB/s vs NVMe PCIe 4.0 ceiling: ~7,500 MB/s")
                )
            }
            totalCapacityGb < 600.0 -> {
                UpgradeRecommendation(
                    category = "Hard Drives & Storage",
                    currentHardware = " GB NVMe SSD",
                    status = UpgradeStatus.OPTIONAL,
                    headline = "Capacity Expansion Recommended",
                    recommendedAction = "Current drive is high-speed NVMe, but 512 GB fills rapidly with modern games (50-150 GB each). Add a secondary 2TB M.2 NVMe drive in your second slot.",
                    expectedImpact = "Convenience: Eliminates the need to constantly uninstall games and large apps.",
                    technicalDetails = details + listOf("Speed is optimal; expansion is for storage volume.")
                )
            }
            else -> {
                UpgradeRecommendation(
                    category = "Hard Drives & Storage",
                    currentHardware = " GB NVMe Storage",
                    status = UpgradeStatus.OPTIMAL,
                    headline = "High-Speed NVMe Storage Tier",
                    recommendedAction = "High-speed NVMe PCIe storage with healthy free capacity. No upgrades required.",
                    expectedImpact = "Optimal storage performance.",
                    technicalDetails = details + listOf("Peak random 4K read/write IOPS and low latency")
                )
            }
        }
    }
}