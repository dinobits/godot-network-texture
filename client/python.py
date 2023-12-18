import cv2, socket, time, base64

# t = 124195
# print()
# print(t.to_bytes(4))

# print(bytes([124195]))


# exit()

vid = cv2.VideoCapture(9) 
if not vid.isOpened():
        print('Video source not found...')
        exit()
            
ret, frame = vid.read()

BUFF_SIZE = 65536
# client_socket = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
# client_socket.setsockopt(socket.SOL_SOCKET,socket.SO_RCVBUF,BUFF_SIZE)
host_name = socket.gethostname()
host_ip = 'localhost'
port = 9082

fps,st,frames_to_count,cnt = (0,0,20,0)

while True:
    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):
        client_socket.close()
        break

    try:
        client_socket = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        # client_socket = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
        client_socket.connect((host_ip, port))
    except Exception as ex:
        print(ex)

    while (vid.isOpened()):
        _, frame = vid.read()
        # encoded,buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY,1])
        encoded,buffer = cv2.imencode('.png', frame)
        # message = base64.b64encode(buffer)
        try:
            size = buffer.size
            # print(size)
            b = size.to_bytes(4, 'little')
            client_socket.send(b)
            client_socket.send(buffer)
            # client_socket.sendto(buffer, (host_ip, port))
            # exit()
        except Exception as ex:
            print(ex)
            client_socket.close()
            break

        frame = cv2.putText(frame,'FPS: '+str(fps),(10,40),cv2.FONT_HERSHEY_SIMPLEX,0.7,(0,0,255),2)
        cv2.imshow('TRANSMITTING VIDEO',frame)

        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            break

        if cnt == frames_to_count:
            try:
                fps = round(frames_to_count/(time.time()-st))
                st=time.time()
                cnt=0
            except:
                pass
        cnt+=1
    if key == ord('q'):
        break

vid.release()
cv2.destroyAllWindows()

exit()

#https://pyshine.com/Send-video-over-UDP-socket-in-Python/

BUFF_SIZE = 65536
client_socket = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
client_socket.setsockopt(socket.SOL_SOCKET,socket.SO_RCVBUF,BUFF_SIZE)
host_name = socket.gethostname()
host_ip = '192.168.1.102'#  socket.gethostbyname(host_name)
print(host_ip)
port = 9999
message = b'Hello'

client_socket.sendto(message,(host_ip,port))
fps,st,frames_to_count,cnt = (0,0,20,0)
while True:
	packet,_ = client_socket.recvfrom(BUFF_SIZE)
	data = base64.b64decode(packet,' /')
	npdata = np.fromstring(data,dtype=np.uint8)
	frame = cv2.imdecode(npdata,1)
	frame = cv2.putText(frame,'FPS: '+str(fps),(10,40),cv2.FONT_HERSHEY_SIMPLEX,0.7,(0,0,255),2)
	cv2.imshow("RECEIVING VIDEO",frame)
	key = cv2.waitKey(1) & 0xFF
	if key == ord('q'):
		client_socket.close()
		break
	if cnt == frames_to_count:
		try:
			fps = round(frames_to_count/(time.time()-st))
			st=time.time()
			cnt=0
		except:
			pass
	cnt+=1



exit()
# define a video capture object 
vid = cv2.VideoCapture(9) 
  
while(True): 
      
    # Capture the video frame 
    # by frame 
    ret, frame = vid.read() 
  
    # Display the resulting frame 
    cv2.imshow('frame', frame) 
      
    # the 'q' button is set as the 
    # quitting button you may use any 
    # desired button of your choice 
    if cv2.waitKey(1) & 0xFF == ord('q'): 
        break
  
# After the loop release the cap object 
vid.release() 
# Destroy all the windows 
cv2.destroyAllWindows()