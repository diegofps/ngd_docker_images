#!/usr/bin/env python3

from pyfacedetectioncnn import FaceDetectionCNN

import pyinotify
import traceback
import asyncio
import sys
import cv2
import os


fc=FaceDetectionCNN()

class Handler(pyinotify.ProcessEvent):
    def process_IN_CLOSE_WRITE(self, event):
        try:
            print("Detected event for IN_CLOSE_WRITE:", event.pathname)

            size = os.path.getsize(event.pathname)

            if size >= 140:
                img = cv2.imread(event.pathname, cv2.IMREAD_COLOR)
                print("img read")
                fc.read(img)
                print("faces detected:", fc.result())

            else:
                print("Size is too small", event.pathname, size)

        except Exception as err:
            traceback.print_exc()
            print(err)
            print("sorry :/")
        sys.stdout.flush()


TARGET = os.getenv('MONITOR_TARGET', '/target')

wm = pyinotify.WatchManager()
handler = Handler()
notifier = pyinotify.Notifier(wm, default_proc_fun=handler)
wm.add_watch(TARGET, pyinotify.IN_CLOSE_WRITE)

notifier.loop()
notifier.stop()
