# Network Configuration Guide

## API Base URL Configuration

The app is configured to use `http://10.0.2.2:3005` as the default API base URL. This configuration works across different network setups:

### Why `10.0.2.2`?

- **Android Emulator**: `10.0.2.2` is the special IP address that Android emulators use to access the host machine's localhost
- **Cross-Network Compatibility**: This IP works regardless of your network configuration changes
- **No Manual Updates**: You don't need to change the IP address when switching networks

### Alternative Configurations

If you need to use a different IP address, you can:

1. **Create a `.env` file** in the project root:
   ```
   API_BASE_URL=http://your-ip-address:3005
   ```

2. **For Physical Android Device**: Use your computer's actual IP address:
   ```
   API_BASE_URL=http://192.168.1.100:3005
   ```

3. **For iOS Simulator**: Use localhost:
   ```
   API_BASE_URL=http://127.0.0.1:3005
   ```

### LoopBack4 Server Configuration

Make sure your LoopBack4 server is configured to accept connections from all interfaces:

```javascript
// In your LoopBack4 application configuration
const config = {
  rest: {
    port: 3005,
    host: '0.0.0.0'  // Accept connections from all interfaces
  }
};
```

### Testing Connection

To test if your server is accessible:

1. **From Host Machine**: `curl http://127.0.0.1:3005/user-management/count`
2. **From Android Emulator**: The app will automatically use `10.0.2.2:3005`

### Benefits of This Configuration

✅ **Network Agnostic**: Works on any network without configuration changes  
✅ **Development Friendly**: No need to update IP addresses when switching networks  
✅ **Cross-Platform**: Works with Android emulators, iOS simulators, and physical devices  
✅ **Production Ready**: Can be easily overridden for production deployments  

### Troubleshooting

If you experience connection issues:

1. **Check if LoopBack4 server is running** on port 3005
2. **Verify server is listening on `0.0.0.0`** not just `localhost`
3. **Check firewall settings** if using physical devices
4. **Use the connection status indicator** in the app to verify connectivity
