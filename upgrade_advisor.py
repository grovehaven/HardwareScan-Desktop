class UpgradeAdvisor:
    @staticmethod
    def evaluate_memory(mem):
        if not mem:
            return {
                'category': 'Memory (RAM)',
                'current': 'Scanning...',
                'status': 'OPTIONAL',
                'headline': 'Memory Telemetry Required',
                'action': 'Inspect memory specifications.',
                'impact': 'N/A',
                'details': []
            }
        total_gb = mem.get('total_gb', 8.0)
        details = [
            f"Total Installed RAM: {total_gb} GB",
            f"Virtual Memory / Swap: {mem.get('swap_total_gb', 0)} GB",
            "Multi-channel memory architecture enabled"
        ]
        if total_gb < 8.0:
            return {
                'category': 'Memory (RAM)',
                'current': f"{total_gb} GB RAM",
                'status': 'CRITICAL_UPGRADE',
                'headline': 'Low Memory Capacity Pressure',
                'action': 'Upgrade RAM to at least 16 GB to prevent pagefile thrashing and app freezes.',
                'impact': 'High: Eliminates system stuttering and browser tab reloads.',
                'details': details
            }
        elif total_gb < 16.0:
            return {
                'category': 'Memory (RAM)',
                'current': f"{total_gb} GB RAM",
                'status': 'RECOMMENDED',
                'headline': 'Optimal Standard Workload RAM',
                'action': '8 GB to 12 GB RAM is adequate for daily tasks. Consider 16 GB+ for heavy multi-tasking.',
                'impact': 'Moderate: Headroom for creative apps and high-end gaming.',
                'details': details
            }
        else:
            return {
                'category': 'Memory (RAM)',
                'current': f"{total_gb} GB RAM",
                'status': 'OPTIMAL',
                'headline': 'High-Performance Memory Tier',
                'action': 'Your system memory capacity provides optimal performance for all desktop workloads.',
                'impact': 'Optimal memory bandwidth achieved.',
                'details': details
            }

    @staticmethod
    def evaluate_cpu(cpu):
        if not cpu:
            return {
                'category': 'Processor (CPU)',
                'current': 'Scanning...',
                'status': 'OPTIONAL',
                'headline': 'CPU Telemetry Required',
                'action': 'Inspect processor specifications.',
                'impact': 'N/A',
                'details': []
            }
        cores = cpu.get('logical_cores', 4)
        model = cpu.get('model', 'Processor')
        details = [
            f"Architecture: {cpu.get('architecture', 'x86_64')} ({cores} Cores)",
            f"Instruction Set: {'64-Bit' if cpu.get('is_64bit') else '32-Bit'}",
        ]
        if cores < 4:
            return {
                'category': 'Processor (CPU)',
                'current': model,
                'status': 'CRITICAL_UPGRADE',
                'headline': 'Legacy Low Core-Count Processor',
                'action': 'Quad-core minimum expected for modern software. Upgrade to a modern 6-core or 8-core CPU.',
                'impact': 'Transformative: Reduces 100% CPU spikes and background lag.',
                'details': details
            }
        else:
            return {
                'category': 'Processor (CPU)',
                'current': model,
                'status': 'OPTIMAL',
                'headline': 'Solid Multi-Core Compute',
                'action': 'Your processor core count provides fast multi-threaded performance.',
                'impact': 'Optimal compute foundation.',
                'details': details
            }

    @staticmethod
    def evaluate_storage(partitions):
        if not partitions:
            return {
                'category': 'Storage Drives',
                'current': 'Scanning...',
                'status': 'OPTIONAL',
                'headline': 'Storage Telemetry Required',
                'action': 'Inspect storage devices.',
                'impact': 'N/A',
                'details': []
            }
        part = partitions[0]
        used_pct = part.get('usage_percent', 50.0)
        free_gb = part.get('free_gb', 50.0)
        details = [
            f"Primary Partition: {part.get('label', 'C:')} ({used_pct}% used)",
            f"Free Capacity: {free_gb} GB remaining",
        ]
        if used_pct >= 85.0:
            return {
                'category': 'Storage Drives',
                'current': f"{used_pct}% Full ({free_gb} GB Free)",
                'status': 'CRITICAL_UPGRADE',
                'headline': 'Storage Capacity Warning (>85% Full)',
                'action': 'Solid state drives experience performance degradation when filled past 85%. Free up space or add secondary NVMe SSD.',
                'impact': 'High: Restores peak flash write speeds and IOPS.',
                'details': details
            }
        else:
            return {
                'category': 'Storage Drives',
                'current': f"{part.get('total_gb', 0)} GB Storage ({free_gb} GB Free)",
                'status': 'OPTIMAL',
                'headline': 'Healthy Storage Capacity',
                'action': 'Storage drive has healthy free capacity and high sustained random IOPS speeds.',
                'impact': 'Optimal storage health.',
                'details': details
            }
