#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket, select

# #Function to broadcast chat messages to all connected clients
# def broadcast_data (sock, message):
# 	#Do not send the message to master socket and the client who has send us the message
# 	print("send msg:", message)
# 	for socket in CONNECTION_LIST:
# 		if socket != server_socket and socket != sock :
# 			try :
# 				socket.send(message)
# 			except :
# 				# broken socket connection may be, chat client pressed ctrl+c for example
# 				socket.close()
# 				CONNECTION_LIST.remove(socket)

def send2Lua(sock, updateLuaList):
	#Do not send the message to master socket and the client who has send us the message
	if len(updateLuaList) > 0:
		message = ''
		for x in updateLuaList:
			message += message and ' ' + x or x
			print('lua file:', x)
		for socket in CONNECTION_LIST:
			if socket != server_socket and socket != sock :
				try :
					socket.send(message)
				except :
					# broken socket connection may be, chat client pressed ctrl+c for example
					socket.close()
					CONNECTION_LIST.remove(socket)

if __name__ == "__main__":     
	updateLuaList = []
    # List to keep track of socket descriptors
	CONNECTION_LIST = []
	RECV_BUFFER = 128 # Advisable to keep it as an exponent of 2
	PORT = 3630

	server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	# this has no effect, why ?
	server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
	server_socket.bind(("localhost", PORT))
	server_socket.listen(5)

	# Add server socket to the list of readable connections
	CONNECTION_LIST.append(server_socket)

	print "server started on port " + str(PORT)

	while 1:
		# Get the list sockets which are ready to be read through select
		read_sockets, write_sockets, error_sockets = select.select(CONNECTION_LIST, [], [])

		for sock in read_sockets:
			#New connection
			if sock == server_socket:
				# Handle the case in which there is a new connection recieved through server_socket
				sockfd, addr = server_socket.accept()
				CONNECTION_LIST.append(sockfd)
				print "Client (%s, %s) connected" % addr
				# broadcast_data(sockfd, "[%s:%s] entered room\n" % addr)
			#Some incoming message from a client
			else:
				# Data recieved from client, process it
				try:
					#In Windows, sometimes when a TCP program closes abruptly,
					# a "Connection reset by peer" exception will be thrown
					data = sock.recv(RECV_BUFFER)
					if data:
						if cmp(data, 'updateLua'.encode()) == 0:
							send2Lua(sock, updateLuaList)
							updateLuaList = []
						else:
							data = data.replace('.lua', '')
							if data.find('src\\'):
								data = data.split('src\\')[1]
							elif data.find('scripts\\'):
								data = data.split('scripts\\')[1]
							data = data.replace('\\', '.')
							if not data in updateLuaList:
								updateLuaList.append(data)
				except:
					# broadcast_data(sock, "Client (%s, %s) is offline" % addr)
					print "Client (%s, %s) is offline" % addr
					sock.close()
					CONNECTION_LIST.remove(sock)
					continue
	server_socket.close()