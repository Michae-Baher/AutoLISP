(defun c:WindFM (/ regobj lineobj regarea linelen mtextpt result mtextObj)
  ;; Prompt user to select a region
  (setq regobj (entsel "\nSelect region: "))
  ;; Check if a region was selected
  (if (and regobj (eq "REGION" (cdr (assoc 0 (entget (car regobj))))))
    (progn
      ;; Prompt user to select a line
      (setq lineobj (entsel "\nSelect line: "))
      ;; Check if a line was selected
      (if (and lineobj (eq "LINE" (cdr (assoc 0 (entget (car lineobj))))))
        (progn
          ;; Calculate the area of the region
          (setq regarea (vla-get-area (vlax-ename->vla-object (car regobj))))
	  (setq wind_stress (getreal "Please input the wind stress kg/m^2:"))
	  (setq force (/ (* regarea wind_stress) 1000000)) 
          ;; Calculate the length of the line
          (setq linelen (distance (cdr (assoc 10 (entget (car lineobj))))
                                  (cdr (assoc 11 (entget (car lineobj))))))
          ;; Calculate the moment which is the product of the force and the length
          (setq moment (/ (* force linelen) 1000))

          ;; Find the midpoint of the line for placing the MText
          (setq mtextpt_force (polar (cdr (assoc 10 (entget (car lineobj))))
                               (angle (cdr (assoc 10 (entget (car lineobj))))
                                      (cdr (assoc 11 (entget (car lineobj)))))
                               (/ linelen 2)))
	  ;; Find the 2nd thrice of the line for placing the MText
          (setq mtextpt_moment (polar (cdr (assoc 10 (entget (car lineobj))))
                               (angle (cdr (assoc 10 (entget (car lineobj))))
                                      (cdr (assoc 11 (entget (car lineobj)))))
                               (* 2 (/ linelen 3))))
          ;; Create the MText object in ModelSpace
          (setq mtextObj_moment (vla-addMText
                          (vla-get-modelspace
                          (vla-get-activedocument (vlax-get-acad-object)))
                          (vlax-3d-point mtextpt_moment) ; Convert midpoint to a 3D point for VLA
                          0 ; Width of the MText (0 for no line wrap)
                          (strcat "M= " (rtos moment 2 2)) ; Content of the MText
                         )
          )
	   (setq mtextObj_force (vla-addMText
                          (vla-get-modelspace
                          (vla-get-activedocument (vlax-get-acad-object)))
                          (vlax-3d-point mtextpt_force) ; Convert midpoint to a 3D point for VLA
                          0 ; Width of the MText (0 for no line wrap)
                          (strcat "F= " (rtos force 2 2)) ; Content of the MText
                         )
          )
          ;; Set the text height
          (vla-put-Height mtextObj_force 300) ; Set the height to 300
	  (vla-put-Height mtextObj_moment 300) ; Set the height to 300
        )
        (alert "Invalid selection. Please select a line.")
      )
    )
    (alert "Invalid selection. Please select a region.")
  )
  ;; Clean up by unsetting temporary variables
  (setq regobj nil lineobj nil regarea nil linelen nil mtextpt nil result nil mtextObj nil)
  (princ)
)

(princ "\nType 'WindFM' to run the command.")