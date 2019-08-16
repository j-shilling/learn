;;; learn.el --- a minor mode for learn labs            -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Jake Shilling

;; Author: Jake Shilling <shilling.jake@gmail.com>
;; Keywords: learn
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Quickly test and submit learn labs from Emacs.

;;; Code:

(require 'comint)

(defun learn-find-lab-root-directory ()
  "Evaluate the root directory of current learn lab.

Starting at the directory which holds the file associated with
the current buffer, work up the directory hierarchy looking for a
directory that contains a .learn file.  Return nil if not found
or if the current buffer is not associated with any file."
  (if buffer-file-name
      (locate-dominating-file (file-name-directory buffer-file-name) ".learn")))

(defun learn-get-buffer ()
  "Return a buffer for the output of a learn process.

Create a new buffer for a learn process to run in.  If a learn
buffer already exists, kill that buffer to stop the
process.  Configure the buffer to be read-only and capable of
displaying ANSI colors."
  (when (get-buffer "*learn*")
    (kill-buffer "*learn*"))
  (let ((*learn* (get-buffer-create "*learn*")))
    (with-current-buffer *learn*
      (ansi-color-for-comint-mode-on)
      (comint-mode)
      (read-only-mode 1))
    *learn*))

(defun learn-start-process (&rest prog-args)
  "Start an asynchronous process by calling learn.

The learn gem must be appropriately installed in 'exec-path'.
PROG-ARGS will be passed to the program as command line
arguments."
  (let ((root-directory (learn-find-lab-root-directory)))
    (if root-directory
	(let ((default-directory root-directory)
	      (*learn* (learn-get-buffer)))
	  (display-buffer *learn* 'display-buffer-pop-up-window)
	  (set-process-filter
	   (apply 'start-process "*learn*" *learn* "learn" prog-args)
	   'comint-output-filter))
      (error "You don't appear to be in a Learn lesson's directory"))))

(defun learn-test ()
  "Run learn test for the current lab."
  (interactive)
  (learn-start-process "test"))

(defun learn-test-fast-fail ()
  "Run learn test --fail-fast."
  (interactive)
  (learn-start-process "test" "--fail-fast"))

(defun learn-submit ()
  "Run learn submit for the current lab."
  (interactive)
  (learn-start-process "submit"))

(provide 'learn)
;;; learn.el ends here
