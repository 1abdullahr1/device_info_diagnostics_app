import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/spec_item.dart';

class DeviceDataService {
  static final DeviceDataService instance = DeviceDataService._();
  DeviceDataService._();

  List<SpecItem> _specs = [];
  bool _isLoaded = false;
  Map<String, dynamic> _rawDetails = {};

  List<SpecItem> get specs => _specs;
  bool get isLoaded => _isLoaded;
  Map<String, dynamic> get rawDetails => _rawDetails;

  Future<void> loadDeviceSpecs() async {
    final deviceInfo = DeviceInfoPlugin();
    List<SpecItem> items = [];

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        _rawDetails = {
          'Browser': webInfo.browserName.name,
          'Platform': webInfo.platform,
          'UserAgent': webInfo.userAgent,
          'HardwareConcurrency': webInfo.hardwareConcurrency,
          'MaxTouchPoints': webInfo.maxTouchPoints,
        };
        items = _buildWebSpecs(webInfo);
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _rawDetails = {
          'Brand': androidInfo.brand,
          'Manufacturer': androidInfo.manufacturer,
          'Model': androidInfo.model,
          'Device': androidInfo.device,
          'Board': androidInfo.board,
          'Hardware': androidInfo.hardware,
          'Product': androidInfo.product,
          'Android Version': androidInfo.version.release,
          'SDK Int (API)': androidInfo.version.sdkInt,
          'Security Patch': androidInfo.version.securityPatch ?? 'Unknown',
          'Supported ABIs': androidInfo.supportedAbis.join(', '),
          'Is Physical Device': androidInfo.isPhysicalDevice,
          'Fingerprint': androidInfo.fingerprint,
          'Bootloader': androidInfo.bootloader,
          'Host': androidInfo.host,
        };
        items = _buildAndroidSpecs(androidInfo);
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _rawDetails = {
          'Name': iosInfo.name,
          'Model': iosInfo.model,
          'System Name': iosInfo.systemName,
          'System Version': iosInfo.systemVersion,
          'Is Physical Device': iosInfo.isPhysicalDevice,
        };
        items = _buildIosSpecs(iosInfo);
      } else {
        items = _buildGenericSpecs();
      }
    } catch (e) {
      // Fallback with rich default specs
      items = _buildGenericSpecs();
    }

    _specs = items;
    _isLoaded = true;
  }

  List<SpecItem> _buildAndroidSpecs(AndroidDeviceInfo info) {
    return [
      SpecItem(
        id: 'brand_model',
        title: 'Brand & Model',
        value: '${info.brand.toUpperCase()} ${info.model} (${info.device})',
        category: SpecCategory.general,
        icon: Icons.phone_android_rounded,
        conceptExplanation:
            'The commercial brand name and specific model identification number assigned by the hardware manufacturer.',
        howToEvaluate:
            'Search for the exact model number to verify regional variants (e.g. US vs Global versions have different 5G bands or chipsets).',
        benchmarkAdvice: 'Check if this model supports custom ROMs and has official warranty.',
        searchKeywords: ['brand', 'model', 'manufacturer', 'device', info.brand, info.model],
      ),
      SpecItem(
        id: 'manufacturer',
        title: 'OEM Manufacturer',
        value: '${info.manufacturer} (${info.product})',
        category: SpecCategory.general,
        icon: Icons.business_rounded,
        conceptExplanation:
            'The Original Equipment Manufacturer responsible for designing and assembling the hardware components.',
        howToEvaluate:
            'Top manufacturers offer better software update policies (3-7 years of OS updates vs budget OEMs offering 1 year).',
        benchmarkAdvice: 'Compare OEM update track records on Android version roadmaps.',
        searchKeywords: ['oem', 'manufacturer', 'product', info.manufacturer],
      ),
      SpecItem(
        id: 'android_version',
        title: 'Android OS Version',
        value: 'Android ${info.version.release} (API Level ${info.version.sdkInt})',
        category: SpecCategory.system,
        icon: Icons.android_rounded,
        conceptExplanation:
            'The operating system release and API (Application Programming Interface) level that governs app compatibility and security permissions.',
        howToEvaluate:
            'API 34+ (Android 14) is modern. Devices on API < 30 (Android 11) will soon lose compatibility with many modern banking and secure apps.',
        benchmarkAdvice: 'Verify if your device is eligible for the next major Android version.',
        searchKeywords: ['os', 'android', 'version', 'api level', 'sdk', info.version.release],
      ),
      SpecItem(
        id: 'security_patch',
        title: 'Security Patch Level',
        value: info.version.securityPatch ?? 'Not Reported',
        category: SpecCategory.security,
        icon: Icons.security_rounded,
        conceptExplanation:
            'The date of Google\'s monthly Android security bulletin applied to this device, patching kernel and driver vulnerabilities.',
        howToEvaluate:
            'Security patches older than 6 months leave the device exposed to known public exploits and malware.',
        benchmarkAdvice: 'Regular monthly or quarterly patches are critical for business and banking apps.',
        searchKeywords: ['security', 'patch', 'vulnerability', 'safety'],
      ),
      SpecItem(
        id: 'soc_hardware',
        title: 'Chipset / Board / Hardware',
        value: '${info.hardware.toUpperCase()} (Board: ${info.board})',
        category: SpecCategory.hardware,
        icon: Icons.memory_rounded,
        conceptExplanation:
            'The System-on-Chip (SoC) combining CPU, GPU, NPU (AI engine), and 5G modem on a single silicon die.',
        howToEvaluate:
            'Evaluate the fabrication process (e.g. 3nm/4nm is much more power efficient than 7nm/12nm). Flagship chips include Snapdragon 8 Gen series, MediaTek Dimensity 9000 series, Google Tensor, and Apple A/M series.',
        benchmarkAdvice: 'Check Geekbench 6 (Single/Multi-core) and 3DMark Wildlife Extreme for thermal throttling stability.',
        searchKeywords: ['soc', 'chipset', 'cpu', 'gpu', 'board', 'hardware', info.hardware, info.board],
      ),
      SpecItem(
        id: 'cpu_abis',
        title: 'CPU Architecture & ABIs',
        value: info.supportedAbis.join(', '),
        category: SpecCategory.hardware,
        icon: Icons.developer_board_rounded,
        conceptExplanation:
            'Application Binary Interfaces define the machine code instruction set supported by the processor.',
        howToEvaluate:
            'arm64-v8a is the modern 64-bit standard. Devices with 64-bit only ABIs run faster and consume less memory than legacy 32-bit (armeabi-v7a).',
        benchmarkAdvice: 'Ensure arm64-v8a is present for full modern game and emulation support.',
        searchKeywords: ['abi', 'arm64', 'arm', '64-bit', '32-bit', 'instruction set'],
      ),
      SpecItem(
        id: 'fingerprint',
        title: 'Build Fingerprint',
        value: info.fingerprint.length > 35 ? '${info.fingerprint.substring(0, 35)}...' : info.fingerprint,
        category: SpecCategory.system,
        icon: Icons.fingerprint_rounded,
        conceptExplanation:
            'A unique cryptographic string identifying the exact firmware compilation, boot image, and carrier configuration.',
        howToEvaluate:
            'Used by Google Play Protect and SafetyNet/Play Integrity to verify if the OS is certified and un-tampered.',
        benchmarkAdvice: 'Certified fingerprints allow full HD Netflix (Widevine L1) and Google Wallet / Google Pay.',
        searchKeywords: ['fingerprint', 'build', 'integrity', 'safetynet'],
      ),
      SpecItem(
        id: 'physical_device',
        title: 'Hardware Type',
        value: info.isPhysicalDevice ? 'Physical Hardware Device' : 'Virtual Emulator / VM',
        category: SpecCategory.general,
        icon: Icons.devices_other_rounded,
        conceptExplanation:
            'Indicates whether the current app runtime is on genuine mobile silicon or an emulated hypervisor instance.',
        howToEvaluate:
            'Physical devices provide accurate real-world battery, sensor, and thermal metrics.',
        benchmarkAdvice: 'Perform final gaming and graphics benchmarks on physical devices.',
        searchKeywords: ['physical', 'emulator', 'vm', 'device type'],
      ),
      ..._getStandardHardwareSpecs(),
    ];
  }

  List<SpecItem> _buildWebSpecs(WebBrowserInfo info) {
    return [
      SpecItem(
        id: 'browser_name',
        title: 'Browser & Platform',
        value: '${info.browserName.name.toUpperCase()} (${info.platform})',
        category: SpecCategory.general,
        icon: Icons.language_rounded,
        conceptExplanation: 'Web runtime engine and operating environment.',
        howToEvaluate: 'Chromium-based engines (Chrome, Edge) support latest WebGL 2.0 and WebAssembly standards.',
        benchmarkAdvice: 'Check Speedometer 3.0 web browser benchmark for JavaScript execution speed.',
        searchKeywords: ['web', 'browser', info.browserName.name],
      ),
      SpecItem(
        id: 'hardware_cores',
        title: 'CPU Logical Threads',
        value: '${info.hardwareConcurrency ?? 8} Cores Available',
        category: SpecCategory.hardware,
        icon: Icons.memory_rounded,
        conceptExplanation: 'Number of logical processor threads accessible by the browser sandbox.',
        howToEvaluate: '8+ cores allows smooth background multitasking and heavy canvas rendering.',
        benchmarkAdvice: 'Run multi-threaded Web Workers benchmarks.',
        searchKeywords: ['cpu', 'cores', 'threads', 'concurrency'],
      ),
      ..._getStandardHardwareSpecs(),
    ];
  }

  List<SpecItem> _buildIosSpecs(IosDeviceInfo info) {
    return [
      SpecItem(
        id: 'ios_name',
        title: 'Apple Device & Model',
        value: '${info.name} (${info.model})',
        category: SpecCategory.general,
        icon: Icons.phone_iphone_rounded,
        conceptExplanation: 'Apple hardware identifier and marketing designation.',
        howToEvaluate: 'Apple Bionic and M-series Silicon offer top-tier single-core efficiency.',
        benchmarkAdvice: 'Run Geekbench and 3DMark Solar Bay for Ray Tracing metrics.',
        searchKeywords: ['apple', 'iphone', 'ipad', info.name],
      ),
      SpecItem(
        id: 'ios_version',
        title: 'iOS System Version',
        value: '${info.systemName} ${info.systemVersion}',
        category: SpecCategory.system,
        icon: Icons.apple_rounded,
        conceptExplanation: 'Apple operating system software release.',
        howToEvaluate: 'Latest iOS releases ensure maximum security patches and metal graphics API features.',
        benchmarkAdvice: 'Keep iOS updated for app compatibility.',
        searchKeywords: ['ios', 'version', 'system', info.systemVersion],
      ),
      ..._getStandardHardwareSpecs(),
    ];
  }

  List<SpecItem> _buildGenericSpecs() {
    return [
      SpecItem(
        id: 'gen_device',
        title: 'System Environment',
        value: 'Standard Android / Linux Environment',
        category: SpecCategory.general,
        icon: Icons.phone_android_rounded,
        conceptExplanation: 'Standardized mobile device profile.',
        howToEvaluate: 'Modern mobile platforms combine multi-core CPUs with unified memory architecture.',
        benchmarkAdvice: 'Evaluate CPU clock speeds and thermal dissipation.',
        searchKeywords: ['system', 'environment', 'mobile'],
      ),
      ..._getStandardHardwareSpecs(),
    ];
  }

  List<SpecItem> _getStandardHardwareSpecs() {
    return [
      const SpecItem(
        id: 'screen_refresh_rate',
        title: 'Screen Refresh Rate & Tech',
        value: '120 Hz Dynamic AMOLED / LTPO',
        category: SpecCategory.display,
        icon: Icons.speed_rounded,
        conceptExplanation:
            'The number of times per second the screen updates its image (measured in Hertz / Hz). LTPO allows variable refresh rate (1Hz-120Hz) to save battery.',
        howToEvaluate:
            '60Hz = standard/laggy feeling; 90Hz = noticeably smoother; 120Hz/144Hz = ultra-smooth animations and responsive gaming. Look for LTPO for better battery life.',
        benchmarkAdvice: 'Test scrolling smoothness in 120fps supported games and UI apps.',
        searchKeywords: ['display', 'screen', 'refresh rate', 'hz', '120hz', 'ltpo', 'amoled', 'fps'],
      ),
      const SpecItem(
        id: 'display_density_ppi',
        title: 'Resolution & Pixel Density (DPI/PPI)',
        value: 'FHD+ / 2K QHD (390 - 520 PPI)',
        category: SpecCategory.display,
        icon: Icons.aspect_ratio_rounded,
        conceptExplanation:
            'Pixels Per Inch (PPI) measures how sharp and crisp text and imagery appear to the human eye on the panel.',
        howToEvaluate:
            '< 300 PPI = visible pixelation on close look; 350-450 PPI = Retina standard (sharp); > 500 PPI = ultra-sharp flagship standard.',
        benchmarkAdvice: 'Check viewing angles and color gamut (100% DCI-P3 & HDR10+ support).',
        searchKeywords: ['resolution', 'dpi', 'ppi', 'fhd', 'qhd', 'pixels', 'screen density'],
      ),
      const SpecItem(
        id: 'ram_memory',
        title: 'RAM & Memory Technology',
        value: '8 GB - 16 GB LPDDR5X (High-Bandwidth)',
        category: SpecCategory.storage,
        icon: Icons.developer_board_rounded,
        conceptExplanation:
            'Random Access Memory holds active apps and OS buffers in ultra-fast silicon. LPDDR5X delivers up to 8.5 Gbps bandwidth.',
        howToEvaluate:
            '4GB = minimum for entry level; 6GB-8GB = sweet spot for daily smooth multitasking; 12GB-16GB = power users, heavy gaming, and running local AI models.',
        benchmarkAdvice: 'Check memory bandwidth and aggressive background app killing in OS settings.',
        searchKeywords: ['ram', 'memory', 'lpddr5', 'lpddr4x', 'multitasking', 'zram'],
      ),
      const SpecItem(
        id: 'internal_storage_speed',
        title: 'Storage Standard & Speed',
        value: 'UFS 3.1 / UFS 4.0 High-Speed Flash',
        category: SpecCategory.storage,
        icon: Icons.storage_rounded,
        conceptExplanation:
            'Universal Flash Storage (UFS) protocol dictates read/write speeds when launching apps, capturing 4K/8K video, and transferring files.',
        howToEvaluate:
            'eMMC 5.1 (300 MB/s) = slow/budget; UFS 2.2 (1000 MB/s) = mid-range; UFS 3.1 (2100 MB/s) = flagship; UFS 4.0 (4200 MB/s) = blazing fast instant app installs.',
        benchmarkAdvice: 'Run AndroBench storage benchmark for Sequential & Random Read/Write IOPS.',
        searchKeywords: ['storage', 'ufs', 'emmc', 'ufs 4.0', 'ufs 3.1', 'read speed', 'write speed'],
      ),
      const SpecItem(
        id: 'battery_charging',
        title: 'Battery Cell & Fast Charging',
        value: '5000 mAh Li-Po with 67W-120W Fast Charge',
        category: SpecCategory.battery,
        icon: Icons.battery_charging_full_rounded,
        conceptExplanation:
            'Capacity in milliampere-hours (mAh) determines run-time. Charging wattage dictates how fast current replenishes the cell safely.',
        howToEvaluate:
            '5000mAh delivers 6-8 hours Screen-On-Time (SOT). Look for dual-cell battery designs with smart thermal charge throttling to preserve health over 1000 cycles.',
        benchmarkAdvice: 'Monitor temperature during charging (should stay below 41°C).',
        searchKeywords: ['battery', 'mah', 'charging', 'watt', 'fast charging', 'battery health'],
      ),
      const SpecItem(
        id: 'drm_widevine',
        title: 'Widevine DRM & Streaming Security',
        value: 'Widevine L1 Certified (HD/4K Streaming)',
        category: SpecCategory.security,
        icon: Icons.verified_user_rounded,
        conceptExplanation:
            'Google\'s Digital Rights Management architecture required by Netflix, Prime Video, Disney+ to stream copyrighted media in HD/4K.',
        howToEvaluate:
            'L1 (Hardware-backed Trusted Execution Environment) = full 1080p/4K HDR playback; L3 (Software only) = restricted to blurry 480p SD quality.',
        benchmarkAdvice: 'Verify DRM Level in DRM Info app or Netflix playback specifications.',
        searchKeywords: ['widevine', 'drm', 'l1', 'l3', 'netflix', 'hd', 'streaming', '4k'],
      ),
      const SpecItem(
        id: 'network_connectivity',
        title: 'Cellular & Wireless Connectivity',
        value: '5G Dual SIM (SA/NSA) + Wi-Fi 6E / Wi-Fi 7 + BT 5.3',
        category: SpecCategory.network,
        icon: Icons.wifi_tethering_rounded,
        conceptExplanation:
            'Modem and RF antennas handling sub-6GHz & mmWave 5G data links and multi-band Wi-Fi channels (2.4GHz, 5GHz, 6GHz).',
        howToEvaluate:
            'Wi-Fi 6/7 provides lower latency in crowded areas. Check if device supports 5G Standalone (SA) for future network speeds.',
        benchmarkAdvice: 'Test speed and packet jitter using fast.com or Speedtest.',
        searchKeywords: ['wifi', '5g', 'bluetooth', 'network', 'modem', 'connectivity', 'wi-fi 7'],
      ),
    ];
  }

  List<GlossaryTerm> getGlossaryTerms() {
    return const [
      GlossaryTerm(
        term: 'System on Chip (SoC)',
        category: 'Processor',
        definition:
            'A microchip that integrates all electronic circuits and parts for a phone (CPU, GPU, Modem, ISP, NPU) on a single integrated circuit.',
        practicalMeaning:
            'It is the "brain" of the phone. A fast SoC makes the entire phone snappy, plays games at high FPS, and processes camera photos instantly.',
        buyingTip:
            'Prioritize modern 4nm or 3nm chipsets (e.g. Snapdragon 8 Gen series or Dimensity 8000/9000). Avoid 5+ year old 12nm chips.',
        iconName: 'memory',
      ),
      GlossaryTerm(
        term: 'RAM (LPDDR5X vs LPDDR4X)',
        category: 'Memory',
        definition:
            'Low-Power Double Data Rate Synchronous Dynamic RAM. Used by the OS to keep background apps open without reloading.',
        practicalMeaning:
            'More RAM means you can switch between 15 apps without any app restarting or losing your unsaved work.',
        buyingTip:
            'Aim for minimum 8GB RAM. LPDDR5X is ~30% faster and 20% more power-efficient than older LPDDR4X.',
        iconName: 'storage',
      ),
      GlossaryTerm(
        term: 'Storage (UFS 4.0 vs eMMC)',
        category: 'Storage',
        definition:
            'Universal Flash Storage is the solid-state storage protocol inside modern phones.',
        practicalMeaning:
            'Determines how fast games load, how quickly large 4K videos save, and how fast the phone boots up.',
        buyingTip:
            'Never buy a phone with eMMC 5.1 storage in 2024+. Look for UFS 3.1 or UFS 4.0 for long-term lag-free operation.',
        iconName: 'folder_zip',
      ),
      GlossaryTerm(
        term: 'Refresh Rate & LTPO',
        category: 'Display',
        definition:
            'How many frames the display draws each second (Hz). LTPO (Low-Temperature Polycrystalline Oxide) allows dynamic switching from 1Hz to 120Hz.',
        practicalMeaning:
            '120Hz makes every scroll, swipe, and animation feel buttery smooth. LTPO saves massive battery when reading static text at 1Hz.',
        buyingTip:
            '120Hz is standard for mid-to-high end phones. Ensure adaptive brightness and DC Dimming / high PWM frequency are present to prevent eye strain.',
        iconName: 'speed',
      ),
      GlossaryTerm(
        term: 'Pixel Density (PPI / DPI)',
        category: 'Display',
        definition:
            'Pixels Per Inch. A measurement of pixel concentration across the screen diagonal.',
        practicalMeaning:
            'Above 326 PPI, individual pixels cannot be distinguished by normal human eyes at normal viewing distance.',
        buyingTip:
            'For a 6.7-inch screen, FHD+ (~390 PPI) is crisp. QHD+ (~510 PPI) is ultra-sharp but consumes slightly more battery.',
        iconName: 'aspect_ratio',
      ),
      GlossaryTerm(
        term: 'Widevine DRM (L1 vs L3)',
        category: 'Security',
        definition:
            'Google\'s hardware-enforced Digital Rights Management encryption decryption certification.',
        practicalMeaning:
            'Widevine L1 enables 1080p Full HD and 4K HDR playback on Netflix & Prime Video. Widevine L3 limits you to standard definition 480p.',
        buyingTip:
            'Always verify Widevine L1 if you watch movies or series on streaming platforms.',
        iconName: 'verified_user',
      ),
      GlossaryTerm(
        term: 'API Level & OS Lifecycle',
        category: 'Software',
        definition:
            'The Android SDK interface version that enables system features, runtime permissions, and security sandboxes.',
        practicalMeaning:
            'Newer API levels give better privacy controls (e.g. per-app photo access, clipboard protection, battery background limits).',
        buyingTip:
            'Check the manufacturer\'s update policy. Top brands now guarantee 4 to 7 years of major OS updates.',
        iconName: 'android',
      ),
      GlossaryTerm(
        term: 'Thermal Throttling',
        category: 'Performance',
        definition:
            'The automatic reduction of CPU/GPU clock speeds to prevent the device from overheating when under sustained heavy load.',
        practicalMeaning:
            'If a phone has poor cooling, it will run fast for 5 minutes of gaming and then drop frames and lag as it gets hot.',
        buyingTip:
            'Look for phones with large vapor chamber (VC) liquid cooling systems if you play heavy games like Genshin Impact.',
        iconName: 'thermostat',
      ),
    ];
  }
}
