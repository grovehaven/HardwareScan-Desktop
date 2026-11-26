import customtkinter as ctk
import threading
import time
from hardware_scanner import HardwareScanner
from upgrade_advisor import UpgradeAdvisor

ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

COLOR_BG = "#0F172A"
COLOR_SURFACE = "#182234"
COLOR_CARD = "#1E293B"
COLOR_BORDER = "#334155"
COLOR_CYAN = "#06B6D4"
COLOR_BLUE = "#3B82F6"
COLOR_GREEN = "#10B981"
COLOR_ORANGE = "#F59E0B"
COLOR_RED = "#EF4444"
COLOR_TEXT_PRIMARY = "#F8FAFC"
COLOR_TEXT_SECONDARY = "#94A3B8"

class CompactInfoRow(ctk.CTkFrame):
    def __init__(self, master, label, value, label_width=170, **kwargs):
        super().__init__(master, fg_color="transparent", **kwargs)
        self.lbl_title = ctk.CTkLabel(
            self, text=label, width=label_width, anchor="w",
            text_color=COLOR_TEXT_SECONDARY, font=ctk.CTkFont(size=12)
        )
        self.lbl_title.pack(side="left", padx=(0, 8), pady=2)

        self.lbl_val = ctk.CTkLabel(
            self, text=str(value), anchor="w",
            text_color=COLOR_TEXT_PRIMARY, font=ctk.CTkFont(size=12, weight="bold")
        )
        self.lbl_val.pack(side="left", fill="x", expand=True, pady=2)

class MetricCard(ctk.CTkFrame):
    def __init__(self, master, title, value="", subtitle="", progress=None, color=COLOR_CYAN, **kwargs):
        super().__init__(master, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8, **kwargs)
        self.title_lbl = ctk.CTkLabel(self, text=title, text_color=COLOR_TEXT_SECONDARY, font=ctk.CTkFont(size=11), anchor="w")
        self.title_lbl.pack(fill="x", padx=10, pady=(8, 2))

        self.val_lbl = ctk.CTkLabel(self, text=value, text_color=COLOR_TEXT_PRIMARY, font=ctk.CTkFont(size=18, weight="bold"), anchor="w")
        self.val_lbl.pack(fill="x", padx=10, pady=0)

        self.sub_lbl = ctk.CTkLabel(self, text=subtitle, text_color=COLOR_TEXT_SECONDARY, font=ctk.CTkFont(size=10), anchor="w")
        self.sub_lbl.pack(fill="x", padx=10, pady=(0, 4))

        if progress is not None:
            self.pbar = ctk.CTkProgressBar(self, height=4, progress_color=color, fg_color=COLOR_BG)
            self.pbar.set(progress)
            self.pbar.pack(fill="x", padx=10, pady=(2, 8))

    def update_metrics(self, value, subtitle="", progress=None):
        self.val_lbl.configure(text=value)
        if subtitle:
            self.sub_lbl.configure(text=subtitle)
        if progress is not None and hasattr(self, 'pbar'):
            self.pbar.set(progress)

class HardwareScanApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Hardware Scan All - PC & Mobile Diagnostics")
        self.geometry("1100x720")
        self.configure(fg_color=COLOR_BG)

        self.scanner = HardwareScanner()
        self.running = True

        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)

        self._build_sidebar()
        self._build_content_area()

        self.show_dashboard()

        self.poll_thread = threading.Thread(target=self._realtime_poll_loop, daemon=True)
        self.poll_thread.start()

    def _build_sidebar(self):
        self.sidebar = ctk.CTkFrame(self, width=180, fg_color=COLOR_SURFACE, corner_radius=0)
        self.sidebar.grid(row=0, column=0, sticky="nsew")

        title = ctk.CTkLabel(
            self.sidebar, text="Hardware Scan All",
            text_color=COLOR_CYAN, font=ctk.CTkFont(size=15, weight="bold")
        )
        title.pack(padx=16, pady=(20, 20))

        self.nav_buttons = {}
        items = [
            ("Dashboard", self.show_dashboard),
            ("Upgrade Path", self.show_upgrades),
            ("Processor", self.show_processor),
            ("Memory", self.show_memory),
            ("Storage", self.show_storage),
            ("Graphics", self.show_graphics),
            ("Network", self.show_network),
            ("System", self.show_system),
            ("Peripherals", self.show_peripherals),
        ]

        for name, cmd in items:
            btn = ctk.CTkButton(
                self.sidebar, text=name, anchor="w",
                fg_color="transparent", text_color=COLOR_TEXT_SECONDARY,
                hover_color=COLOR_CARD, font=ctk.CTkFont(size=12),
                command=cmd
            )
            btn.pack(fill="x", padx=8, pady=2)
            self.nav_buttons[name] = btn

    def _set_active_nav(self, active_name):
        for name, btn in self.nav_buttons.items():
            if name == active_name:
                btn.configure(fg_color=COLOR_CARD, text_color=COLOR_CYAN)
            else:
                btn.configure(fg_color="transparent", text_color=COLOR_TEXT_SECONDARY)

    def _build_content_area(self):
        self.content_frame = ctk.CTkScrollableFrame(self, fg_color=COLOR_BG)
        self.content_frame.grid(row=0, column=1, sticky="nsew", padx=16, pady=16)

    def _clear_content(self):
        for child in self.content_frame.winfo_children():
            child.destroy()

    def show_dashboard(self):
        self._set_active_nav("Dashboard")
        self._clear_content()

        hdr = ctk.CTkLabel(
            self.content_frame, text="Hardware Diagnostics",
            font=ctk.CTkFont(size=20, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w"
        )
        hdr.pack(fill="x", pady=(0, 2))

        sub = ctk.CTkLabel(
            self.content_frame, text="Real-time telemetry and component inspection",
            font=ctk.CTkFont(size=12), text_color=COLOR_TEXT_SECONDARY, anchor="w"
        )
        sub.pack(fill="x", pady=(0, 12))

        grid = ctk.CTkFrame(self.content_frame, fg_color="transparent")
        grid.pack(fill="x", pady=(0, 12))
        grid.grid_columnconfigure((0, 1, 2, 3), weight=1)

        cpu_snap = self.scanner.get_cpu_snapshot()
        mem_snap = self.scanner.get_memory_snapshot()
        parts = self.scanner.get_partitions()
        batt_snap = self.scanner.get_battery()

        self.card_cpu = MetricCard(grid, "CPU Utilization", f"{cpu_snap['total_load_percent']}%", cpu_snap['model'], cpu_snap['total_load_percent']/100, COLOR_CYAN)
        self.card_cpu.grid(row=0, column=0, padx=4, pady=4, sticky="nsew")

        self.card_mem = MetricCard(grid, "RAM Usage", f"{mem_snap['usage_percent']}%", f"{mem_snap['used_gb']} / {mem_snap['total_gb']} GB", mem_snap['usage_percent']/100, COLOR_BLUE)
        self.card_mem.grid(row=0, column=1, padx=4, pady=4, sticky="nsew")

        p0 = parts[0] if parts else {'usage_percent': 0, 'free_gb': 0}
        self.card_disk = MetricCard(grid, "Primary Storage", f"{p0['usage_percent']}%", f"{p0['free_gb']} GB free", p0['usage_percent']/100, COLOR_ORANGE)
        self.card_disk.grid(row=0, column=2, padx=4, pady=4, sticky="nsew")

        self.card_batt = MetricCard(grid, "Battery", f"{batt_snap['remainingPercent']}%", batt_snap['estimatedTimeRemaining'], batt_snap['remainingPercent']/100, COLOR_GREEN)
        self.card_batt.grid(row=0, column=3, padx=4, pady=4, sticky="nsew")

        sys_card = ctk.CTkFrame(self.content_frame, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8)
        sys_card.pack(fill="x", pady=8)

        sys_title = ctk.CTkLabel(sys_card, text="System Summary", font=ctk.CTkFont(size=14, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w")
        sys_title.pack(fill="x", padx=14, pady=(10, 4))

        overview = self.scanner.get_overview()
        gpus = self.scanner.get_gpus()

        CompactInfoRow(sys_card, "Operating System", overview['os_name']).pack(fill="x", padx=14)
        CompactInfoRow(sys_card, "OS Build / Kernel", overview['os_version']).pack(fill="x", padx=14)
        CompactInfoRow(sys_card, "Manufacturer & Model", f"{overview['manufacturer']} {overview['model']}").pack(fill="x", padx=14)
        CompactInfoRow(sys_card, "Primary GPU Acceleration", gpus[0]['name'] if gpus else "N/A").pack(fill="x", padx=14)
        CompactInfoRow(sys_card, "System Boot Time", overview['boot_time']).pack(fill="x", padx=14)

    def show_processor(self):
        self._set_active_nav("Processor")
        self._clear_content()

        cpu = self.scanner.get_cpu_snapshot()

        hdr = ctk.CTkLabel(self.content_frame, text="Central Processing Unit (CPU)", font=ctk.CTkFont(size=20, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w")
        hdr.pack(fill="x", pady=(0, 2))

        sub = ctk.CTkLabel(self.content_frame, text=cpu['model'], font=ctk.CTkFont(size=14, weight="bold"), text_color=COLOR_CYAN, anchor="w")
        sub.pack(fill="x", pady=(0, 12))

        card = ctk.CTkFrame(self.content_frame, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8)
        card.pack(fill="x", pady=8)

        ctk.CTkLabel(card, text="Processor Specifications", font=ctk.CTkFont(size=14, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w").pack(fill="x", padx=14, pady=(10, 4))

        CompactInfoRow(card, "Manufacturer / Vendor", cpu['vendor']).pack(fill="x", padx=14)
        CompactInfoRow(card, "Microarchitecture", cpu['architecture']).pack(fill="x", padx=14)
        CompactInfoRow(card, "Physical Cores", str(cpu['physical_cores'])).pack(fill="x", padx=14)
        CompactInfoRow(card, "Logical Processors (Threads)", str(cpu['logical_cores'])).pack(fill="x", padx=14)
        CompactInfoRow(card, "64-Bit Instruction Set", "Yes (64-Bit)" if cpu['is_64bit'] else "No").pack(fill="x", padx=14)
        CompactInfoRow(card, "CPU Core Voltage", f"{cpu['voltage_volts']} V").pack(fill="x", padx=14, pady=(0, 10))

        ctk.CTkLabel(self.content_frame, text="Individual CPU Core Real-Time Utilization", font=ctk.CTkFont(size=16, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w").pack(fill="x", pady=(16, 8))

        core_grid = ctk.CTkFrame(self.content_frame, fg_color="transparent")
        core_grid.pack(fill="x")
        core_grid.grid_columnconfigure((0, 1, 2, 3), weight=1)

        self.core_cards = []
        for i, load in enumerate(cpu['core_loads']):
            freq = cpu['core_frequencies_ghz'][i] if i < len(cpu['core_frequencies_ghz']) else 2.8
            mc = MetricCard(core_grid, f"Core #{i}", f"{load}%", f"{freq} GHz", load/100, COLOR_CYAN if load < 80 else COLOR_RED)
            row = i // 4
            col = i % 4
            mc.grid(row=row, column=col, padx=4, pady=4, sticky="nsew")
            self.core_cards.append(mc)

    def show_upgrades(self):
        self._set_active_nav("Upgrade Path")
        self._clear_content()

        cpu = self.scanner.get_cpu_snapshot()
        mem = self.scanner.get_memory_snapshot()
        parts = self.scanner.get_partitions()

        ctk.CTkLabel(self.content_frame, text="Hardware Upgrade Path", font=ctk.CTkFont(size=20, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w").pack(fill="x", pady=(0, 2))

        rec_mem = UpgradeAdvisor.evaluate_memory(mem)
        rec_cpu = UpgradeAdvisor.evaluate_cpu(cpu)
        rec_disk = UpgradeAdvisor.evaluate_storage(parts)

        for rec in [rec_mem, rec_cpu, rec_disk]:
            card = ctk.CTkFrame(self.content_frame, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8)
            card.pack(fill="x", pady=8)

            ctk.CTkLabel(card, text=f"{rec['category']} - {rec['headline']}", font=ctk.CTkFont(size=14, weight="bold"), text_color=COLOR_CYAN, anchor="w").pack(fill="x", padx=14, pady=(10, 4))
            CompactInfoRow(card, "Current Hardware", rec['current']).pack(fill="x", padx=14)
            CompactInfoRow(card, "Recommended Action", rec['action']).pack(fill="x", padx=14)
            CompactInfoRow(card, "Expected Gain", rec['impact']).pack(fill="x", padx=14, pady=(0, 10))

    def show_memory(self):
        self._set_active_nav("Memory")
        self._clear_content()
        mem = self.scanner.get_memory_snapshot()

        ctk.CTkLabel(self.content_frame, text="Memory & RAM Architecture", font=ctk.CTkFont(size=20, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w").pack(fill="x", pady=(0, 12))

        card = ctk.CTkFrame(self.content_frame, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8)
        card.pack(fill="x", pady=8)

        CompactInfoRow(card, "Physical RAM Installed", f"{mem['total_gb']} GB").pack(fill="x", padx=14, pady=(10, 2))
        CompactInfoRow(card, "RAM In Use", f"{mem['used_gb']} GB ({mem['usage_percent']}%)").pack(fill="x", padx=14)
        CompactInfoRow(card, "Available Memory", f"{mem['available_gb']} GB").pack(fill="x", padx=14)
        CompactInfoRow(card, "Virtual / Swap Memory", f"{mem['swap_total_gb']} GB").pack(fill="x", padx=14, pady=(0, 10))

    def show_storage(self):
        self._set_active_nav("Storage")
        self._clear_content()
        parts = self.scanner.get_partitions()

        ctk.CTkLabel(self.content_frame, text="Logical Storage Partitions", font=ctk.CTkFont(size=20, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w").pack(fill="x", pady=(0, 12))

        for p in parts:
            card = ctk.CTkFrame(self.content_frame, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8)
            card.pack(fill="x", pady=6)
            CompactInfoRow(card, "Partition Drive", f"{p['label']} [{p['drive_letter']}]").pack(fill="x", padx=14, pady=(8, 2))
            CompactInfoRow(card, "Storage Capacity", f"{p['used_gb']} GB used of {p['total_gb']} GB ({p['usage_percent']}% Used)").pack(fill="x", padx=14, pady=(0, 8))

        ctk.CTkLabel(self.content_frame, text="File Types Stored", font=ctk.CTkFont(size=18, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w").pack(fill="x", pady=(16, 8))

        file_categories = [
            ("Graphics & Pictures", "3,420 Files / 12.4 GB", "JPEG, PNG, WEBP, HEIC, GIF"),
            ("Videos", "185 Files / 28.6 GB", "MP4, MKV, MOV, AVI"),
            ("Programs & Executables", "64 Files / 8.2 GB", "APK, AAB, EXE, ELF, SH"),
            ("Apps & Applications", "142 Applications / 24.1 GB", "Installed User Apps & System Services"),
        ]

        for title, count_size, formats in file_categories:
            card = ctk.CTkFrame(self.content_frame, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8)
            card.pack(fill="x", pady=4)
            CompactInfoRow(card, title, count_size).pack(fill="x", padx=14, pady=(8, 2))
            CompactInfoRow(card, "Supported Formats", formats).pack(fill="x", padx=14, pady=(0, 8))

    def show_graphics(self):
        self._set_active_nav("Graphics")
        self._clear_content()
        gpus = self.scanner.get_gpus()
        displays = self.scanner.get_displays()

        ctk.CTkLabel(self.content_frame, text="Graphics & Displays", font=ctk.CTkFont(size=20, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w").pack(fill="x", pady=(0, 12))

        for gpu in gpus:
            card = ctk.CTkFrame(self.content_frame, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8)
            card.pack(fill="x", pady=6)
            CompactInfoRow(card, "Graphics Adapter", gpu['name']).pack(fill="x", padx=14, pady=(8, 2))
            CompactInfoRow(card, "VRAM / Driver", f"{gpu['vram_mb']} MB ({gpu['driver']})").pack(fill="x", padx=14, pady=(0, 8))

        for disp in displays:
            card = ctk.CTkFrame(self.content_frame, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8)
            card.pack(fill="x", pady=6)
            CompactInfoRow(card, "Display Monitor", disp['deviceName']).pack(fill="x", padx=14, pady=(8, 2))
            CompactInfoRow(card, "Resolution & Refresh Rate", f"{disp['resolution']} @ {disp['refreshRateHz']} Hz").pack(fill="x", padx=14, pady=(0, 8))

    def show_network(self):
        self._set_active_nav("Network")
        self._clear_content()
        nets = self.scanner.get_networks()

        ctk.CTkLabel(self.content_frame, text="Network Connectivity", font=ctk.CTkFont(size=20, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w").pack(fill="x", pady=(0, 12))

        for net in nets:
            card = ctk.CTkFrame(self.content_frame, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8)
            card.pack(fill="x", pady=6)
            CompactInfoRow(card, "Network Adapter", net['displayName']).pack(fill="x", padx=14, pady=(8, 2))
            CompactInfoRow(card, "IPv4 Address", ", ".join(net['ipv4Addresses'])).pack(fill="x", padx=14)
            CompactInfoRow(card, "Gateway & Speed", f"{net['gateway']} ({net['speedMbps']} Mbps)").pack(fill="x", padx=14, pady=(0, 8))

    def show_system(self):
        self._set_active_nav("System")
        self._clear_content()
        overview = self.scanner.get_overview()

        ctk.CTkLabel(self.content_frame, text="System & Platform Firmware", font=ctk.CTkFont(size=20, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w").pack(fill="x", pady=(0, 12))

        card = ctk.CTkFrame(self.content_frame, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8)
        card.pack(fill="x", pady=6)
        CompactInfoRow(card, "Operating System", overview['os_name']).pack(fill="x", padx=14, pady=(8, 2))
        CompactInfoRow(card, "Kernel / Build", overview['os_version']).pack(fill="x", padx=14)
        CompactInfoRow(card, "Architecture", overview['os_arch']).pack(fill="x", padx=14)
        CompactInfoRow(card, "Boot Timestamp", overview['boot_time']).pack(fill="x", padx=14, pady=(0, 8))

    def show_peripherals(self):
        self._set_active_nav("Peripherals")
        self._clear_content()
        periphs = self.scanner.get_peripherals()

        ctk.CTkLabel(self.content_frame, text="Connected Peripherals", font=ctk.CTkFont(size=20, weight="bold"), text_color=COLOR_TEXT_PRIMARY, anchor="w").pack(fill="x", pady=(0, 12))

        for p in periphs:
            card = ctk.CTkFrame(self.content_frame, fg_color=COLOR_CARD, border_color=COLOR_BORDER, border_width=1, corner_radius=8)
            card.pack(fill="x", pady=4)
            CompactInfoRow(card, p['name'], f"{p['vendor']} ({p['category']})").pack(fill="x", padx=14, pady=8)

    def _realtime_poll_loop(self):
        while self.running:
            try:
                cpu = self.scanner.get_cpu_snapshot()
                mem = self.scanner.get_memory_snapshot()
                batt = self.scanner.get_battery()

                if hasattr(self, 'card_cpu'):
                    self.card_cpu.update_metrics(f"{cpu['total_load_percent']}%", cpu['model'], cpu['total_load_percent']/100)
                if hasattr(self, 'card_mem'):
                    self.card_mem.update_metrics(f"{mem['usage_percent']}%", f"{mem['used_gb']} / {mem['total_gb']} GB", mem['usage_percent']/100)
                if hasattr(self, 'card_batt'):
                    self.card_batt.update_metrics(f"{batt['remainingPercent']}%", batt['estimatedTimeRemaining'], batt['remainingPercent']/100)

                if hasattr(self, 'core_cards'):
                    for i, mc in enumerate(self.core_cards):
                        if i < len(cpu['core_loads']):
                            load = cpu['core_loads'][i]
                            freq = cpu['core_frequencies_ghz'][i] if i < len(cpu['core_frequencies_ghz']) else 2.8
                            mc.update_metrics(f"{load}%", f"{freq} GHz", load/100)
            except Exception:
                pass
            time.sleep(1)

    def destroy(self):
        self.running = False
        super().destroy()

if __name__ == "__main__":
    app = HardwareScanApp()
    app.mainloop()
