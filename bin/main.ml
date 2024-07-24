let root_handler _ = Dream.html {|
                                _
                               | |
   ___    _ __     __ _   ___  | |_    ___
  / _ \  | '_ \   / _` | / __| | __|  / _ \
 | (_) | | |_) | | (_| | \__ \ | |_  |  __/
  \___/  | .__/   \__,_| |___/  \__|  \___|
         | |
         |_|


Welcome to opaste! Curl the /post endpoint with the file contents as data and recieve the link to it!
Like so:
curl localhost:8080/post --data @file.txt

To get the past just run
curl localhost:8080/get/<paste id>
|}

let file_count = ref 0 (* this _will_ break *)

let record_file body =
  let filename = Printf.sprintf "workdir/%d" !file_count in
    let oc = open_out_bin filename in
      Printf.fprintf oc "%s" body;
      close_out oc;
      file_count := !file_count + 1;
    filename

let read_file filename =
    Dream.log "reading file %s" filename;
    let ch = open_in_bin filename in
    let s = really_input_string ch (in_channel_length ch) in
    close_in ch;
    s

let post_handler request =
  let%lwt body = Dream.body request in
    Dream.respond
    @@ Printf.sprintf "Recorded as %s\n"
    @@ record_file body

let get_handler request =
  Dream.log "Handling request";
  Dream.html
  @@ read_file
  @@ Printf.sprintf "workdir/%s" (* THIS IS A HUGE RISK  *)
  @@ Dream.param request "num"

let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [

    Dream.get "/" root_handler;

    Dream.post "/post" post_handler;

    Dream.get "/get/:num" get_handler;
  ]
