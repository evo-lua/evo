local TcpSocket = C_Networking.TcpSocket

local function assertExportsAPI(socket, exportedApiSurface)
	local fauxTcpHandle = {} -- Can't spy on userdata calls, so replace it with a table placeholder
	socket.handle = fauxTcpHandle
	for name, targetFunctionName in pairs(exportedApiSurface) do
		socket.handle[targetFunctionName] = function() end -- Will be spied on, functionality doesn't matter
		assertEquals(type(TcpSocket[name]), "function", "Should export function " .. name)
		assertFunctionCalls(function() socket[name](socket) end, fauxTcpHandle, targetFunctionName)
	end
end

describe("TcpSocket", function()

	it("should define a class name", function()
		assertEquals(typeof(TcpSocket), "TcpSocket")
	end)

	it("should expose libuv's generic uv_tcp_t API", function()
		local exportedApiSurface = {
			Open = "open",
			SetNoDelay = "nodelay",
			SetKeepAlive = "keepalive",
			SetMultiAcceptMode = "simultaneous_accepts",
			Bind = "bind",
			GetPeerName = "getpeername",
			GetSocketName = "getsockname",
			Connect = "connect",
			SetWriteQueueSize = "write_queue_size",
			Reset = "close_reset",
		}

		local socket = TcpSocket()
		assertExportsAPI(socket, exportedApiSurface)
	end)

	it("should expose libuv's generic uv_stream_t API", function()
		local exportedApiSurface = {
			Shutdown = "shutdown",
			Listen = "listen",
			Accept = "accept",
			StartReading = "read_start",
			StopReading = "read_stop",
			Write = "write",
			IsReadable ="is_readable",
			IsWritable = "is_writable",
			SetBlockingMode = "stream_set_blocking",
			GetWriteQueueSize = "stream_get_write_queue_size",
		}

		local socket = TcpSocket()
		assertExportsAPI(socket, exportedApiSurface)
	end)

	it("should expose libuv's generic uv_handle_t API", function()
		local exportedApiSurface = {
			IsActive = "is_active",
			IsClosing = "is_closing",
			Close = "close",
			Reference = "ref",
			Unreference = "unref",
			HasReference = "has_ref",
			SetSendBufferSize = "send_buffer_size",
			GetSendBufferSize = "send_buffer_size",
			SetReceiveBufferSize = "recv_buffer_size",
			GetReceiveBufferSize = "recv_buffer_size",
			GetReadOnlyFileDescriptor = "fileno",
			GetTypeInfo = "handle_get_type",
		}
		local socket = TcpSocket()
		assertExportsAPI(socket, exportedApiSurface)
	end)

	it("should store the host name and port of the underlying socket", function()
		local socket = TcpSocket("0.0.0.0", 666)
		assertEquals(socket:GetPort(), 666)
		assertEquals(socket:GetHostName(), "0.0.0.0")
		assertEquals(socket:GetURL(), "tcp://0.0.0.0:666")
	end)

	describe("SetKeepAliveTime", function()
		local socket = TcpSocket()
		it("should fail if the keep alive time passed is not a number", function()
			assertEquals(socket:SetKeepAliveTime(nil), nil)
			assertEquals(socket:SetKeepAliveTime({}), nil)
			assertEquals(socket:SetKeepAliveTime(print), nil)
			assertEquals(socket:SetKeepAliveTime("hi"), nil)
		end)

		it("should fail if the keep alive time passed is a negative number", function()
			assertEquals(socket:SetKeepAliveTime(-1), nil)
			assertEquals(socket:SetKeepAliveTime(-100), nil)
		end)

		it("should forward the TCP_KEEPALIVE setting to the socket if the keepalive time is valid", function()
			assertEquals(socket:SetKeepAliveTime(42), true)

			local hasForwardedKeepAliveTime = false
			local hasSetEnabledFlag = false

			local libuvHandle = socket.handle
			local fauxHandle = {
				keepalive = function(self, enabledFlag, delayInMilliseconds)
					hasForwardedKeepAliveTime = delayInMilliseconds == 100
					hasSetEnabledFlag = enabledFlag == true
				end
			}
			socket.handle = fauxHandle

			local function codeUnderTest()
				socket:SetKeepAliveTime(100)
			end

			assertFunctionCalls(codeUnderTest, socket.handle, "keepalive")

			assertTrue(hasForwardedKeepAliveTime)
			assertTrue(hasSetEnabledFlag)

			socket.handle = libuvHandle
		end)

		it("should disable the TCP_KEEPALIVE setting on the socket if the keepalive time is zero", function()
			assertEquals(socket:SetKeepAliveTime(0), true)

			local hasForwardedKeepAliveTime = false
			local hasSetEnabledFlag = false

			local libuvHandle = socket.handle
			local fauxHandle = {
				keepalive = function(self, enabledFlag, delayInMilliseconds)
					hasForwardedKeepAliveTime = (delayInMilliseconds == 0)
					hasSetEnabledFlag = (enabledFlag == false)
				end
			}
			socket.handle = fauxHandle

			local function codeUnderTest()
				socket:SetKeepAliveTime(0)
			end

			assertFunctionCalls(codeUnderTest, socket.handle, "keepalive")

			assertTrue(hasForwardedKeepAliveTime)
			assertTrue(hasSetEnabledFlag)

			socket.handle = libuvHandle
		end)
	end)

	describe("OnEvent", function()
		local socket = TcpSocket()
		it("should do nothing if no event listener for the passed event ID was registered", function()
			local eventID = "DUMMY_EVENT_DOES_NOT_EXIST"

			assertEquals(socket:OnEvent(eventID), nil)
		end)

		it("should call the registered event listener and pass all arguments if one exists", function()
			local eventID = "DUMMY_EVENT_DOES_NOT_EXIST"

			local didPassArguments = false
			socket[eventID] = function(self, event, arg1, ...)
				didPassArguments = (arg1 == 42) and (event == eventID)
			end

			local function codeUnderTest()
				socket:OnEvent(eventID, 42)
			end
			assertFunctionCalls(codeUnderTest, socket, eventID)
			assertTrue(didPassArguments)
		end)
	end)

end)