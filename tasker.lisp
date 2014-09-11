(defpackage #:cl-tasker
  (:use #:cl #:xml-emitter)
  (:import-from #:xml-emitter)
  (:export :flash
	   :tasker-data))
(in-package :cl-tasker)

(defun get-java-time ()
  (+ (mod (get-internal-real-time) 1000) ; Close enough.
     (* 1000 (- (get-universal-time) 2208988800))))

;;; Make hash tables easier to create.
(set-macro-character #\{
 (lambda (str char)
  (declare (ignore char)) ; Ignore me some warnings
  (let
   ((*readtable* (copy-readtable *readtable* nil))
    (keep-going t))
   (set-macro-character #\} (lambda (stream char)
                             (declare (ignore char) (ignore stream))
                             (setf keep-going nil)))
   (let ((pairs (loop for key = (read str nil nil t)
		   while keep-going
		   for value = (read str nil nil t)
		   collect (list key value)))
	 (retn (gensym)))
     `(let ((,retn (make-hash-table :test #'equal)))
	,@(mapcar
	   (lambda (pair)
	     `(setf (gethash ,(car pair) ,retn) ,(cadr pair)))
	   pairs)
	,retn)))))

(defparameter *action-codes*
  {'FLASH 548

  ;;---- Unimplemented below this line ----

  'NONE -1 ;; Is this a noop?
  'FIRST-PLUGIN-CODE 1000 ; higher are all plugins

  ;Deprecated
  ;; Not sure what to do with these. I can't really test them?
  'TEST-OLD 115
  'TAKE-PHOTO-OLD 10
  'TAKE-PHOTO-SERIES-OLD 11
  'TAKE-PHOTO-CHRON-OLD 12
  'LIST-VARIABLES 594
  'TEST-FILE-OLD 411
  'SET-SPEECH-PARAMS 876
  'NOTIFY 500
  'NOTIFY-LED-RED 510
  'NOTIFY-LED-GREEN 520
  'PERMANENT-NOTIFY 777
  'NOTIFY-VIBRATE 530
  'NOTIFY-SOUND 540
  'POPUP-IMAGE-TASK-NAMES 557
  'POPUP-TASK-ICONS 560
  'POPUP-TASK-NAMES 565
  'KEYGUARD-PATTERN 151

  ; Active
  'ANCHOR 300
  'SET-SMS-APP 252
  'SAY-AFTER 696
  'SHUT-UP 697
  'TORCH 511
  'DPAD 701
  'TYPE 702
  'BUTTON 703
  'NOTIFY-PLAIN 523
  'NOTIFY-LED 525
  'NOTIFY-VIBRATE-2 536
  'NOTIFY-SOUND-2 538
  'CANCEL-NOTIFY 779
  'POPUP 550
  'HTML-POPUP 941
  'MENU 551
  'POPUP-TASK-BUTTONS 552
  'SET-ALARM 566
  'START-TIMER 543
  'CALENDAR-INSERT 567
  'REBOOT 59
  'VIBRATE 61
  'MIDI-PLAY 156
  'VIBRATE-PATTERN 62
  'STATUS-BAR 512
  'CLOSE-SYSTEM-DIALOGS 513
  'MICROPHONE-MUTE 301
  'VOLUME-ALARM 303
  'VOLUME-RINGER 304
  'VOLUME-NOTIFICATION 305
  'VOLUME-CALL 306
  'VOLUME-MUSIC 307
  'VOLUME-SYSTEM 308
  'VOLUME-DTMF 309
  'VOLUME-BT-VOICE 311
  'SILENT-MODE 310
  'SOUND-EFFECTS-ENABLED 136
  'HAPTIC-FEEDBACK 177
  'SPEAKERPHONE-STATUS 254
  'RINGER-VIBRATE 256
  'NOTIFICATION-VIBRATE 258
  'NOTIFICATION-PULSE 259
  'DIALOG-SETTINGS 200
  'DIALOG-ACCESSIBILITY-SETTINGS 236
  'DIALOG-PRIVACY-SETTINGS 238
  'DIALOG-AIRPLANE-MODE-SETTINGS 201
  'DIALOG-ADD-ACCOUNT-SETTINGS 199
  'DIALOG-APN-SETTINGS 202
  'DIALOG-BATTERY-INFO-SETTINGS 251
  'DIALOG-DATE-SETTINGS 203
  'DIALOG-DEVICE-INFO-SETTINGS 198
  'DIALOG-INTERNAL-STORAGE-SETTINGS 204
  'DIALOG-DEVELOPMENT-SETTINGS 205
  'DIALOG-WIFI-SETTINGS 206
  'DIALOG-LOCATION-SOURCE-SETTINGS 208
  'DIALOG-INPUT-METHOD-SETTINGS 210
  'DIALOG-SYNC-SETTINGS 211
  'DIALOG-NFC-SETTINGS 956
  'DIALOG-NFC-SHARING-SETTINGS 957
  'DIALOG-NFC-PAYMENT-SETTINGS  958
  'DIALOG-DREAM-SETTINGS 959
  'DIALOG-WIFI-IP-SETTINGS 212
  'DIALOG-WIRELESS-SETTINGS 214
  'DIALOG-APPLICATION-SETTINGS 216
  'DIALOG-BLUETOOTH-SETTINGS 218
  'DIALOG-ROAMING-SETTINGS 220
  'DIALOG-DISPLAY-SETTINGS 222
  'DIALOG-LOCALE-SETTINGS 224
  'DIALOG-MANAGE-APPLICATION-SETTINGS 226
  'DIALOG-MEMORY-CARD-SETTINGS 227
  'DIALOG-NETWORK-OPERATOR-SETTINGS 228
  'DIALOG-POWER-USAGE-SETTINGS 257
  'DIALOG-QUICK-LAUNCH-SETTINGS 229
  'DIALOG-SECURITY-SETTINGS 230
  'DIALOG-SEARCH-SETTINGS 231
  'DIALOG-SOUND-SETTINGS 232
  'DIALOG-USER-DICTIONARY-SETTINGS 234
  'INPUT-METHOD-SELECT 804
  'POKE-DISPLAY 806
  'SCREEN-BRIGHTNESS-AUTO 808
  'SCREEN-BRIGHTNESS 810
  'SCREEN-OFF-TIMEOUT 812
  'ACCELEROMETER-ROTATION 822
  'STAY-ON-WHILE-PLUGGED-IN 820
  'KEYGUARD-ENABLED 150
  'LOCK 15
  'SYSTEM-LOCK 16
  'SHOW-SOFT-KEYBOARD 987
  'CAR-MODE 988
  'NIGHT-MODE 989
  'SET-LIGHT 999
  'READ-BINARY 776
  'WRITE-BINARY 775
  'READ-LINE 415
  'READ-PARA 416
  'READ-FILE 417
  'MOVE-FILE 400
  'COPY-FILE 404
  'COPY-DIR 405
  'DELETE-FILE 406
  'DELETE-DIR 408
  'MAKE-DIR 409
  'WRITE-TO-FILE 410
  'LIST-FILES 412
  'ZIP-FILE 420
  'UNZIP-FILE 422
  'VIEW-FILE 102
  'BROWSE-FILES 900
  'GET-FIX 902
  'STOP-FIX 901
  'GET-VOICE 903
  'VOICE-COMMAND 904
  'LOAD-IMAGE 188
  'SAVE-IMAGE 187
  'RESIZE-IMAGE 193
  'ROTATE-IMAGE 191
  'FLIP-IMAGE 190
  'FILTER-IMAGE 185
  'CROP-IMAGE 189
  'TAKE-PHOTO-TWO 101
  'ENCRYPT-FILE 434
  'DECRYPT-FILE 435
  'ENTER-PASSPHRASE 436
  'CLEAR-PASSPHRASE 437
  'SET-PASSPHRASE 423
  'ENCRYPT-DIR 428
  'DECRYPT-DIR 429
  'KILL-APP 18
  'LOAD-APP 20
  'LOAD-LAST-APP 22
  'SETCPU 915
  'GO-HOME 25
  'WAIT 30
  'WAIT-UNTIL 35
  'IF 37
  'ENDIF 38
  'ELSE 43
  'FOR 39
  'ENDFOR 40
  'SEARCH 100
  'RUN-SCRIPT 112
  'JAVASCRIPTLET 129
  'JAVASCRIPT 131
  'RUN-SHELL 123
  'REMOUNT 124
  'RETURN 126
  'TEST-NET 341
  'TEST-FILE 342
  'TEST-MEDIA 343
  'TEST-APP 344
  'TEST-VARIABLE 345
  'TEST-PHONE 346
  'TEST-TASKER 347
  'TEST-DISPLAY 348
  'TEST-SYSTEM 349
  'TEST-SCENE 194
  'SCENE-ELEMENT-TEST 195
  'SAY 559
  'SAY-TO-FILE 699
  'SEND-INTENT 877
  'VIEW-URL 104
  'SET-CLIPBOARD 105
  'SET-WALLPAPER 109
  'HTTP-GET 118
  'HTTP-POST 116
  'OPEN-MAP 119
  'ANDROID-MEDIA-CONTROL 443
  'GRAB-MEDIA-BUTTON 490
  'PLAY-RINGTONE 192
  'BEEP 171
  'MORSE 172
  'MUSIC-PLAY 445
  'MUSIC-PLAY-DIR 447
  'MUSIC-STOP 449
  'MUSIC-FORWARD 451
  'MUSIC-BACK 453
  'SCAN-CARD 459
  'RINGTONE 457
  'SOUND-RECORD 455
  'SOUND-RECORD-STOP 657
  'AUTO-SYNC 331
  'AIRPLANE-MODE 333
  'GPS-STATUS 332
  'BLUETOOTH-STATUS 294
  'BLUETOOTH-NAME 295
  'BLUETOOTH-SCO 296
  'BLOCK-CALLS 95
  'DIVERT-CALLS 97
  'REVERT-CALLS 99
  'CONTACTS 909
  'CALL-LOG 910
  'EMAIL-COMPOSE 125
  'SMS-COMPOSE 250
  'MMS-COMPOSE 111
  'TETHER-WIFI 113
  'TETHER-USB 114
  'TAKE-CALL 731
  'RADIO-STATUS 732
  'END-CALL 733
  'SILENCE-RINGER 734
  'MOBILE-NETWORK-MODE 735
  'MAKE-PHONECALL 90
  'MOBILE-DATA-STATUS 450
  'MOBILE-DATA-STATUS-DIRECT 433
  'SEND-TEXT-SMS 41
  'SEND-DATA-SMS 42
  'AIRPLANE-RADIOS 323
  'WIFI-STATUS 425
  'WIFI-NET-CONTROL 426
  'WIFI-SLEEP-POLICY 427
  'WIMAX-STATUS 439
  'SET-TIMEZONE 440
  'CHANGE-ICON-SET 140
  'CHANGE-WIDGET-TEXT 155
  'CHANGE-WIDGET-ICON 152
  'TOGGLE-PROFILE 159
  'QUERY-ACTION 134
  'RUN-TASK 130
  'GOTO 135
  'STOP 137
  'DISABLE-TASKER 139
  'TASKER-LOGGING 283
  'SET-TASKER-ICON 138
  'SET-TASKER-PREF 133
  'CREATE-SCENE 46
  'SHOW-SCENE 47
  'HIDE-SCENE 48
  'DESTROY-SCENE 49
  'SCENE-ELEMENT-VALUE 50
  'SCENE-ELEMENT-FOCUS 68
  'SCENE-ELEMENT-TEXT 51
  'SCENE-ELEMENT-TEXT-COLOUR 54
  'SCENE-ELEMENT-TEXT-SIZE 71
  'SCENE-ELEMENT-BACKGROUND-COLOUR 55
  'SCENE-ELEMENT-BORDER 56
  'SCENE-ELEMENT-POSITION 57
  'SCENE-ELEMENT-SIZE 58
  'SCENE-ELEMENT-ADD-GEOMARKER 60
  'SCENE-ELEMENT-DELETE-GEOMARKER 63
  'SCENE-ELEMENT-WEB-CONTROL 53
  'SCENE-ELEMENT-MAP-CONTROL 64
  'SCENE-ELEMENT-VISIBILITY 65
  'SCENE-ELEMENT-CREATE 69
  'SCENE-ELEMENT-DESTROY 73
  'SCENE-ELEMENT-IMAGE 66
  'SCENE-ELEMENT-DEPTH 67
  'ARRAY-PUSH 355
  'ARRAY-PROCESS 369
  'ARRAY-POP 356
  'ARRAY-CLEAR 357
  'SET-VARIABLE 547
  'SET-VARIABLE-RANDOM 545
  'INC-VARIABLE 888
  'DEC-VARIABLE 890
  'CLEAR-VARIABLE 549
  'SPLIT-VARIABLE 590
  'JOIN-VARIABLE 592
  'QUERY-VARIABLE 595
  'CONVERT-VARIABLE 596
  'SECTION-VARIABLE 597
  'SEARCH-REPLACE-VARIABLE 598
  'ASTRID 371
  'BEYONDPOD 555
  'DAILYROADS 568
  'DUETODAY 599
  'ANDROID-NOTIFIER 558
  'NEWSROB 556
  'OFFICETALK 643
  'JUICE-DEFENDER-DATA 456
  'JUICE-DEFENDER-STATUS 395
  'SLEEPBOT 442
  'SMSBACKUP 553
  'TESLALED 444
  'WIDGETLOCKER 458
  'GENTLEALARM 911
  'ZOOM-ELEMENT-STATE 793
  'ZOOM-ELEMENT-POSITION 794
  'ZOOM-ELEMENT-SIZE 795
  'ZOOM-ELEMENT-VISIBILITY 721
  'ZOOM-ELEMENT-ALPHA 760
  'ZOOM-ELEMENT-IMAGE 761
  'ZOOM-ELEMENT-COLOUR 762
  'ZOOM-ELEMENT-TEXT 740
  'ZOOM-ELEMENT-TEXT-SIZE 741
  'ZOOM-ELEMENT-TEXT-COLOUR 742})

(defparameter *ifops*
  {'-    0
   '~    1
   '!~   2
   '<    3
   '>    4
   '=    5
   '!=   6
   'even 7
   'odd  8
   'set  9
   '!set 10
   '~R   11
   '!~R  12})

(defmacro action (action-code action-id ifclause label &rest arglist)
  ""
  (let ((c action-code)
	(id action-id)
	(ifop (car ifclause))
	(lhs (cadr ifclause))
	(rhs (caddr ifclause))
	(args arglist))
    `(with-tag ("Action" '(("sr" ,(format nil "act~A" id))
			   ("ve" 3)))
       (simple-tag "code" ,c)
       ,(let ((op (gethash ifop *ifops*)))
	     (cond (op
		    `(emit-simple-tags :lhs ,lhs
				       :op ,(gethash ifop *ifops*)
				       :rhs ,rhs))
		   ((and ifop (not op))
		    (warn "Your if clause countained a wrong operation. Try prepending it with :."))))
       ,(if label
	    `(simple-tag "label" ,label))
       (loop for arg in ',args
	  for i from 0 to ,(1- (length args))
	  do (cond ((stringp arg)
		    (simple-tag "Str"
				arg
				`(("sr" ,(format nil "arg~A" i))
				  ("ve" 3))))
		   ((or (typep arg 'boolean) (integerp arg))
		    (simple-tag "Int"
				""
				`(("sr" ,(format nil "arg~A" i))
				  ("val" ,(cond ((integerp arg) arg)
						(arg 1)
						(t 0))))))
		   (t (princ (format nil "Don't know how to handle variable ~A of type ~a" arg (type-of arg)))))))))

(defmacro flash (str &key ((:if ifclause) nil) (id 0) (label nil) (long nil))
  `(action (gethash :flash *action-codes*) ,id ,ifclause ,label ,str ,long))

(defmacro defaction (name &optional args kwargs)
  `(defmacro ,name
       (,@args &key ((:if ifclause) nil)
		 (id 0)
		 (label nil)
		 ,@kwargs)
     `(action (gethash ',',name *action-codes*)
	      ,id
	      ,ifclause
	      ,label
	      ,,@args
	      ,,@(loop for kwarg in kwargs
		    collect (first kwarg)))))

(defaction shut-up)

(defaction javascriptlet (code) ((libraries "") (autoexit t) (timeout 45)))

(defmacro tasker-data (&body body)
  `(with-tag ("TaskerData" '(("sr" "")
			     ("dvi" 1)
			     ("tv" "1.6u2")))
     ,@(loop for (f . args) in body
	  for i from 0 to (1- (length body))
	  collect `(,f ,@args :id ,i))))
