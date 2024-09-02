#!/usr/bin/env tclsh

package require Tk

# Function to handle incoming TCP requests
proc handle_request {sock addr port} {
    # Read the incoming data
    set data [gets $sock]

    # Append the client info and message to the text widget
    .text insert end "Client connected from $addr:$port\n"
    .text insert end "Received data: $data\n"
    .text insert end "--------------------------------\n"
    .text see end ; # Scroll to the end of the text box

    # Send a response back to the ESP32/mock client
    set response "Acknowledged: $data\n"
    puts $sock $response

    # Flush the output to ensure it is sent immediately
    flush $sock

    # Close the connection
    close $sock
}

# Function to start the server
proc start_server {} {
    global server_socket
    set server_socket [socket -server handle_request 9191]

    # Update the UI to show that the server is started
    .text insert end "Server started on port 9191\n"
    .text insert end "--------------------------------\n"
    .text see end
}

# Function to stop the server
proc stop_server {} {
    global server_socket
    if {[info exists server_socket]} {
        close $server_socket
        unset server_socket

        # Update the UI to show that the server is stopped
        .text insert end "Server stopped\n"
        .text insert end "--------------------------------\n"
        .text see end
    } else {
        tk_messageBox -message "Server is not running"
    }
}

# Function to handle the window close event
proc on_closing {} {
    stop_server
    set forever 0  ; # Exit the vwait loop
    exit            ; # Ensure the application exits completely
}

# Creating the main window
wm title . "Tcl/Tk Server Control"

# Bind the WM_DELETE_WINDOW event to on_closing to handle window close properly
wm protocol . WM_DELETE_WINDOW on_closing

# Create a frame to hold the buttons side by side
frame .buttonFrame
pack .buttonFrame -side top -fill x -padx 10 -pady 5

# Start button
button .buttonFrame.start -text "Start Server" -command start_server
pack .buttonFrame.start -side left -padx 10

# Stop button
button .buttonFrame.stop -text "Stop Server" -command stop_server
pack .buttonFrame.stop -side left -padx 10

# Create a text widget to display the messages
text .text -width 60 -height 20 -wrap none
pack .text -side top -fill both -expand true -padx 10 -pady 5

# Add a scrollbar for the text widget
scrollbar .scroll -orient vertical -command ".text yview"
pack .scroll -side right -fill y
.text configure -yscrollcommand ".scroll set"

# Run the application, waiting for events
vwait forever

# #!/usr/bin/env tclsh

# package require Tk

# # Function to handle incoming TCP requests
# proc handle_request {sock addr port} {
#     # Read the incoming data
#     set data [gets $sock]

#     # Process the incoming data
#     puts "Received data from $addr:$port: $data"

#     # Send a response back to the ESP32/mock client
#     set response "Acknowledged: $data\n"
#     puts $sock $response

#     # Flush the output to ensure it is sent immediately
#     flush $sock

#     # Close the connection
#     close $sock
# }

# # Function to start the server
# proc start_server {} {
#     global server_socket
#     set server_socket [socket -server handle_request 9191]

#     tk_messageBox -message "Server started on port 9191"
# }

# # Function to stop the server
# proc stop_server {} {
#     global server_socket
#     if {[info exists server_socket]} {
#         close $server_socket
#         unset server_socket
#         tk_messageBox -message "Server stopped"
#     } else {
#         tk_messageBox -message "Server is not running"
#     }
# }

# # Creating the main window
# wm title . "Tcl/Tk Server Control"

# # Start button
# button .start -text "Start Server" -command start_server
# pack .start -padx 10 -pady 10

# # Stop button
# button .stop -text "Stop Server" -command stop_server
# pack .stop -padx 10 -pady 10

# # Run the application, waiting for events
# vwait forever
