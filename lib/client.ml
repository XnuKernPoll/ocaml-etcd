open Protocol
open Lwt.Infix
       

exception Neither
            
module Client = Cohttp_lwt_unix.Client
module Option = Batteries.Option
                  
          
type result = (Response.t, Error.t) Result.result

let path_string path =
  String.join "/" path

let make_path key =
  ["v2";"keys"] @ key
  |> path_String

       
let ttl_param ?ttl =
  match ttl with
  | Some x ->
     [( "ttl", [(to_string x)] )  ]

  | _ -> []


let decode_error s =
  let res = Error.t_of_yojson s in
  match res with

  | Result.Ok e ->
     Result.Error e
                  
  | Result.Error _ ->
     raise Neither


let decode_response body =
  Cohttp_lwt_body.to_string body >>= fun s ->
  let res = Response.t_of_yojson s in

  let rep = match res with
  | Result.Ok x ->
     Result.Ok x

  | Result.Error ->
     decode_error s
  in

  Lwt.return rep 
                  
     

let put host key ?ttl v =

  let path = make_path key in 
  let uri = Uri.make ~host ~path () in
  let value = Uri.pct_encode v in

  let ttl_p = ttl_param ttl in 
  
  let params = [("value", [value])] @ ttl_p in

  Client.post_form uri path ~params >>= fun (_, body) ->
  decode_response body



let get host key =
  let path = make_path key in
  let uri = Uri.make ~host ~path () in
  Client.get uri >>= fun (_, body) ->
  decode_response body

let delete host key =
  let path = make_path key in
  let uri = Uri.make ~host ~path ()  in
  Client.delete uri >>= fun (_, body) ->
  decode_response body


                  
let create_dir host key ?ttl =
  let path = make_path key in 
  let uri = Uri.make ~host ~path () in

  let ttl_p = ttl_param ttl in
  let params =
    [
      ("ttl", [ttl_p]),
      ("dir", ["true"]) 
    ]
  in

  Client.post_form uri path ~params >>= fun (_, body) ->
  decode_response body


let refresh host key ttl =
  let path = make_path key in
  let uri = Uri.make ~host ~path () in

  let ttl_p = to_string ttl in
  let params =
    [
      ("refresh", ["true"]),
      ("ttl", [ttl_p]),
      ("prevExist", ["true"])
    ]
  in

  Client.post_form uri path ~params >>= fun (_, body) ->
  decode_response body



let list host key ?r:(r=false) () =
  let path = make_path key in
  let query =
    [ ("recursive", [ (string_of_bool r) ] ) ]
  in

  let uri = Uri.make ~host ~path ~query in

  Client.get uri >>= fun (_, body) ->
  decode_response body 
  
  

let rm_dir host key =
  let path = make_path key in
  let query = [("dir", ["true"])] in
  let uri = Uri.make ~host ~path ~query () in

  Client.delete uri >>= fun (_, body) ->
  decode_response body


              

let watch host key cb ?times:(i = 1) () =

  let make_uri ?i () = 
    let path = make_path key in
    let common_q = [  ("wait", ["true"])  ] in  

    let query =
      match i with
      | Some x ->
         let index_q =
           [
             ("waitIndex", [   (string_of_int x) ]  )
           ] in 
         common_q @ index_q

      | None -> common_q 
    in 


    Uri.make ~host ~path ~query ()

  in



  let rec handle_watch ctr ?i () =
    
    if ctr > 1 then
      let url = make_uri ~i () in
      Client.get url >>= fun (_, body) ->
      decode_response body >>= fun res ->

      match res with
      | Result.Ok rep ->
         let i0 = Response.index rep in
         let (i1, ctr0) = (i0 + 1), (ctr - 1) in
         cb rep >>= fun _ ->
         handle_watch ctr0 ~i:i1 ()


      | Result.Error e -> Lwt.fail_with e



    else
      match res with
      | Result.Ok rep -> cb rep
      | Result.Error -> Lwt.fail_with e


                          
         
                
