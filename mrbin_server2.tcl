#!/usr/bin/env tclsh

package require Tk

# Global variables to keep track of connected clients
array set clients {}

# Function to handle incoming TCP requests
proc handle_request {sock addr port} {
    global clients

    # Generate a unique identifier for the client
    set client_id "$addr:$port"
    
    # Store the client socket in the array
    set clients($client_id) $sock
    
    # Add the client to the listbox
    .clientList insert end $client_id

    # Append the client info and message to the text widget
    .messageFrame.text insert end "Client connected from $client_id\n"
    .messageFrame.text insert end "--------------------------------\n"
    .messageFrame.text see end ; # Scroll to the end of the text box

    # Enter a loop to keep the connection open for receiving messages
    fconfigure $sock -blocking 0 -buffering line
    fileevent $sock readable [list receive_message $client_id]
}

# Function to receive messages from clients
proc receive_message {client_id} {
    global clients
    set sock $clients($client_id)
    
    if {[eof $sock]} {
        # If the client has disconnected
        .messageFrame.text insert end "Client $client_id disconnected\n"
        .messageFrame.text insert end "--------------------------------\n"
        .messageFrame.text see end
        close $sock
        unset clients($client_id)
        set idx [.clientList get 0 end] ; # Find the index in the listbox
        .clientList delete [lsearch $idx $client_id]
        return
    }

    # Read the incoming message
    set data [gets $sock]
    .messageFrame.text insert end "Message from $client_id: $data\n"
    .messageFrame.text insert end "--------------------------------\n"
    .messageFrame.text see end
}

# Function to start the server
proc start_server {} {
    global server_socket
    set server_socket [socket -server handle_request 9191]

    # Update the UI to show that the server is started
    .messageFrame.text insert end "Server started on port 9191\n"
    .messageFrame.text insert end "--------------------------------\n"
    .messageFrame.text see end
}

# Function to stop the server
proc stop_server {} {
    global server_socket clients
    if {[info exists server_socket]} {
        # Close all client connections
        foreach client_id [array names clients] {
            close $clients($client_id)
            unset clients($client_id)
        }
        close $server_socket
        unset server_socket

        # Update the UI to show that the server is stopped
        .messageFrame.text insert end "Server stopped\n"
        .messageFrame.text insert end "--------------------------------\n"
        .messageFrame.text see end
        .clientList delete 0 end
    } else {
        tk_messageBox -message "Server is not running"
    }
}

# Function to send a message to the selected client
proc send_message {} {
    global clients
    set selected [.clientList curselection]
    if {[llength $selected] == 0} {
        tk_messageBox -message "Please select a client to send a message to."
        return
    }

    set client_id [.clientList get $selected]
    set sock $clients($client_id)
    set message [.messageEntry get]
    
    if {$message ne ""} {
        puts $sock $message
        flush $sock
        .messageFrame.text insert end "Sent to $client_id: $message\n"
        .messageFrame.text insert end "--------------------------------\n"
        .messageFrame.text see end
        .messageEntry delete 0 end
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

# Create a listbox to display connected clients
label .clientLabel -text "Connected Clients"
pack .clientLabel -side left -padx 10
listbox .clientList -width 30 -height 10
pack .clientList -side left -padx 10 -pady 5 -fill y

# Create a frame to hold the text area and the message input
frame .messageFrame
pack .messageFrame -side right -fill both -expand true -padx 10 -pady 5

# Create a text widget to display the messages
text .messageFrame.text -width 60 -height 15 -wrap none
pack .messageFrame.text -side top -fill both -expand true -padx 10 -pady 5

# Add a scrollbar for the text widget
scrollbar .messageFrame.scroll -orient vertical -command ".messageFrame.text yview"
pack .messageFrame.scroll -side right -fill y
.messageFrame.text configure -yscrollcommand ".messageFrame.scroll set"

# Create an entry widget for typing messages
entry .messageEntry -width 60
pack .messageEntry -side top -fill x -padx 10 -pady 5

# Send message button
button .sendButton -text "Send Message" -command send_message
pack .sendButton -side top -padx 10 -pady 5

# Run the application, waiting for events
vwait forever
