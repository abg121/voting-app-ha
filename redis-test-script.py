import redis
from redis.sentinel import Sentinel
import time
import sys

def test_direct_connection(host, port, password=None):
    """Test direct connection to Redis instance"""
    print(f"\n🔗 Testing DIRECT connection to {host}:{port}")
    try:
        client = redis.Redis(
            host=host,
            port=port,
            password=password,
            socket_timeout=5,
            socket_connect_timeout=5,
            decode_responses=True
        )

        # Test basic operations
        start = time.time()
        ping_result = client.ping()
        info = client.info()

        # Test read/write
        client.set('test_key', 'test_value', ex=10)
        value = client.get('test_key')
        client.delete('test_key')

        latency = (time.time() - start) * 1000

        print(f"✅ SUCCESS:")
        print(f"   - Ping: {ping_result}")
        print(f"   - Role: {info.get('role', 'N/A')}")
        print(f"   - Latency: {latency:.2f}ms")
        print(f"   - Read/Write: ✓")
        return True

    except Exception as e:
        print(f"❌ FAILED: {str(e)}")
        return False

def test_sentinel_connection(sentinel_hosts, master_name, password=None):
    """Test connection via Sentinel"""
    print(f"\n🎯 Testing SENTINEL connection (master: {master_name})")
    try:
        sentinel = Sentinel(
            sentinel_hosts,
            socket_timeout=5,
            password=password,
            sentinel_kwargs={'password': password} if password else {}
        )

        # Get master info
        master_host, master_port = sentinel.discover_master(master_name)
        print(f"   - Discovered master: {master_host}:{master_port}")

        # Test master connection
        master = sentinel.master_for(
            master_name,
            socket_timeout=5,
            password=password,
            decode_responses=True
        )

        start = time.time()
        ping_result = master.ping()
        master.set('sentinel_test', 'value', ex=10)
        value = master.get('sentinel_test')
        master.delete('sentinel_test')
        latency = (time.time() - start) * 1000

        print(f"✅ SENTINEL SUCCESS:")
        print(f"   - Master connection: ✓")
        print(f"   - Operations: ✓")
        print(f"   - Latency: {latency:.2f}ms")
        return True

    except Exception as e:
        print(f"❌ SENTINEL FAILED: {str(e)}")
        return False

def test_haproxy_connection(haproxy_host, haproxy_port, password=None):
    """Test connection through HAProxy"""
    print(f"\n🔄 Testing HAPROXY connection to {haproxy_host}:{haproxy_port}")
    try:
        client = redis.Redis(
            host=haproxy_host,
            port=haproxy_port,
            password=password,
            socket_timeout=5,
            socket_connect_timeout=5,
            decode_responses=True
        )

        start = time.time()
        ping_result = client.ping()
        info = client.info()

        # Test multiple operations
        client.set('haproxy_test', 'haproxy_value', ex=10)
        value = client.get('haproxy_test')
        client.delete('haproxy_test')

        latency = (time.time() - start) * 1000

        print(f"✅ HAPROXY SUCCESS:")
        print(f"   - Ping: {ping_result}")
        print(f"   - Role: {info.get('role', 'N/A')}")
        print(f"   - Latency: {latency:.2f}ms")
        print(f"   - Operations: ✓")
        return True

    except Exception as e:
        print(f"❌ HAPROXY FAILED: {str(e)}")
        return False

def test_sentinel_info(sentinel_hosts, master_name, password=None):
    """Get detailed Sentinel information"""
    print(f"\n📊 Testing SENTINEL INFO for {master_name}")
    for i, (host, port) in enumerate(sentinel_hosts):
        try:
            sentinel_client = redis.Redis(
                host=host,
                port=port,
                password=password,
                socket_timeout=3,
                decode_responses=True
            )

            # Get master info
            master_info = sentinel_client.sentinel_master(master_name)
            slaves = sentinel_client.sentinel_slaves(master_name)
            sentinel_info = sentinel_client.sentinel_sentinels(master_name)

            print(f"Sentinel {i+1} ({host}:{port}):")
            print(f"   - Master: {master_info.get('ip', 'N/A')}:{master_info.get('port', 'N/A')}")
            print(f"   - Status: {master_info.get('flags', 'N/A')}")
            print(f"   - Slaves: {len(slaves)}")
            print(f"   - Sentinels: {len(sentinel_info)}")

        except Exception as e:
            print(f"❌ Sentinel {i+1} ({host}:{port}) failed: {str(e)}")

def main():
    print("🚀 Starting Redis/Sentinel/HAProxy Diagnostic Test")
    print("=" * 60)

    # Configuration - UPDATE THESE VALUES FOR YOUR SETUP
    config = {
        # Direct Redis connections
        'redis_master': {'host': 'redis-a', 'port': 6379, 'password': None},
        'redis_slave': {'host': 'redis-b', 'port': 6380, 'password': None},
        'redis_slave': {'host': 'redis-c', 'port': 6380, 'password': None},

        # Sentinel connections
        'sentinels': [('localhost', 26379), ('localhost', 26380), ('localhost', 26381)],
        'master_name': 'mymaster',

        # HAProxy connection
        'haproxy': {'host': 'localhost', 'port': 6379, 'password': None}
    }

    # Update with your actual values
    print("⚠️  Please update the configuration in the script with your actual values:")
    print("   - Redis master/slave hostnames and ports")
    print("   - Sentinel hostnames and ports")
    print("   - HAProxy hostname and port")
    print("   - Passwords if authentication is enabled")

    # Run tests
    print("\n" + "=" * 60)

    # Test direct connections
    test_direct_connection(
        config['redis_master']['host'],
        config['redis_master']['port'],
        config['redis_master']['password']
    )

    test_direct_connection(
        config['redis_slave']['host'],
        config['redis_slave']['port'],
        config['redis_slave']['password']
    )

    # Test Sentinel
    test_sentinel_connection(
        config['sentinels'],
        config['master_name'],
        config['redis_master']['password']
    )

    # Test HAProxy
    test_haproxy_connection(
        config['haproxy']['host'],
        config['haproxy']['port'],
        config['haproxy']['password']
    )

    # Get detailed Sentinel info
    test_sentinel_info(
        config['sentinels'],
        config['master_name'],
        config['redis_master']['password']
    )

if __name__ == "__main__":
    main()
