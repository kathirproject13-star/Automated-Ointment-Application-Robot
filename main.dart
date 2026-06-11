import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Ointment Robot",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothConnection? connection;
  BluetoothDevice? selectedDevice;
  bool isConnecting = false;
  bool get isConnected => connection != null && connection!.isConnected;

  @override
  void initState() {
    super.initState();
    _askPermissions();
  }

  Future<void> _askPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => isConnecting = true);

    try {
      var newConnection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        connection = newConnection;
        selectedDevice = device;
        isConnecting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Connected to ${device.name}")));

      connection!.input
          ?.listen((data) {
            debugPrint("Data from Arduino: ${ascii.decode(data)}");
          })
          .onDone(() {
            setState(() => connection = null);
          });
    } catch (e) {
      setState(() => isConnecting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Connection failed")));
    }
  }

  void _showDeviceList() async {
    await _askPermissions();

    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      debugPrint("Error fetching devices: $e");
    }

    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No paired devices found")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🔗 Select Bluetooth Device"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: devices.map((d) {
              return ListTile(
                leading: const Icon(Icons.devices),
                title: Text(d.name ?? "Unknown"),
                subtitle: Text(d.address),
                onTap: () {
                  Navigator.pop(context);
                  _connectToDevice(d);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _sendCommand(String command) {
    if (isConnected) {
      connection!.output.add(ascii.encode(command));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.send, color: Colors.white), // 📡 icon
              const SizedBox(width: 8),
              Text("Command Sent: $command"),
            ],
          ),
          backgroundColor: Colors.green, // ✅ success color
          behavior: SnackBarBehavior.floating, // makes it float
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2), // auto-hide after 2s
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("⚠️ Not connected")));
    }
  }

  Widget floatingBtn(
    String label,
    String cmd, {
    double top = 100,
    double? left,
    double? right, // ✅ added right
    double size = 60,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right, // ✅ use right when given
      child: SizedBox(
        width: size,
        height: size,
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(220, 69, 144, 169),
          onPressed: () => _sendCommand(cmd),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 0, 81, 148),
                Color.fromARGB(255, 39, 155, 176),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          isConnected
              ? "✅ Connected: ${selectedDevice?.name ?? ''}"
              : isConnecting
              ? "⏳ Connecting..."
              : "❌ Not Connected",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth, size: 24),
            onPressed: _showDeviceList,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/human_back.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            floatingBtn("Area 1", "A", top: 200, left: 20, size: 140),
            floatingBtn("Area 2", "B", top: 200, right: 20, size: 140),
            floatingBtn("Area 3", "C", top: 370, left: 30, size: 140),
            floatingBtn("Area 4", "D", top: 370, right: 30, size: 140),
            floatingBtn("Area 5", "E", top: 540, left: 30, size: 140),
            floatingBtn("Area 6", "F", top: 540, right: 30, size: 140),
          ],
        ),
      ),
    );
  }
}
