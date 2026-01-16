open Base
open Hardcaml
open Hardcaml.Signal


module I = struct
    type 'a t = 
    { din: 'a[@bits 8]
    ; clear: 'a
    ; clock: 'a
    }
    [@@deriving hardcaml]
end



module O = struct
    type 'a t = 
    { d1 : 'a[@bits 4]
    ; d2 : 'a[@bits 4]
    }
    [@@deriving hardcaml]
end



let max_tracker spec data = 
    Signal.reg_fb spec ~width:8 ~enable:Signal.vdd
      
    ~f:(fun cur -> 
        let firstin = data.:[7,4] in
        let secondin = data.:[3,0] in

        (* Logic Breakdown: if digit_1 is greater than the stored value *)
        (* then update both digit_1 and digit_2, else consider updating *)
        (*                the value of digit_2                          *) 
        
        let mux2_outer_enable = firstin >: cur.:[7,4] in
        let mux2_inner_enable = secondin >: cur.:[3,0] in
        let mux2_inner_res = mux2 mux2_inner_enable (cur.:[7,4] @: secondin) cur in
        mux2 mux2_outer_enable data mux2_inner_res
        
        )


let create (i : _ I.t) =

    let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
    let max_val = max_tracker spec i.din in
    let d1 = max_val.:[7,4] in
    let d2 = max_val.:[3,0] in    

    { O.d1 = d1; O.d2 = d2; }
