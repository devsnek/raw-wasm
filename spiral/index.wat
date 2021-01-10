(module
  (global $width (import "env" "width") i32)
  (global $height (import "env" "height") i32)
  (global $fwidth (import "env" "width") f64)
  (global $fheight (import "env" "height") f64)
  (import "Math" "sin" (func $sin (param f64) (result f64)))
  (import "Math" "cos" (func $cos (param f64) (result f64)))
  (memory (export "memory") 1)
  (global $time (mut f64) (f64.const 0))

  (func $write (param $x i32)
               (param $y i32)
               (param $r i32)
               (param $g i32)
               (param $b i32)
               (local $i i32)
    (i32.add
      (i32.mul
        (i32.const 4)
        (local.get $x))
      (i32.mul
        (i32.const 4)
        (i32.mul
          (global.get $width)
          (local.get $y))))

    local.get $r

    local.get $g
    i32.const 8
    i32.shl
    i32.or

    local.get $b
    i32.const 16
    i32.shl
    i32.or

    i32.const 255
    i32.const 24
    i32.shl
    i32.or

    i32.store
  )

  (func $mapf (param $n f64)
              (param $in_min f64)
              (param $in_max f64)
              (param $out_min f64)
              (param $out_max f64)
              (result f64)
    (f64.add
      (local.get $out_min)
      (f64.div
        (f64.mul
          (f64.sub
            (local.get $n)
            (local.get $in_min))
          (f64.sub
            (local.get $out_max)
            (local.get $out_min)))
        (f64.sub (local.get $in_max) (local.get $in_min))))
  )

  (func (export "draw")
        (local $x i32)
        (local $y i32)
    (call $mapf
      (call $cos (global.get $time))
      (f64.const -1.0)
      (f64.const 1.0)
      (f64.add (f64.const 0.0) (global.get $time))
      (f64.sub (global.get $fwidth) (global.get $time))
    )
    i32.trunc_f64_u
    local.set $x

    (call $mapf
      (call $sin (global.get $time))
      (f64.const -1.0)
      (f64.const 1.0)
      (f64.add (f64.const 0.0) (global.get $time))
      (f64.sub (global.get $fheight) (global.get $time))
    )
    i32.trunc_f64_u
    local.set $y

    (call $write
      (local.get $x)
      (local.get $y)
      (i32.const 128)
      (i32.trunc_f64_u (f64.mul (global.get $time) (f64.const 2)))
      (i32.const 255))

    (global.set $time (f64.add (global.get $time) (f64.const 0.05)))
    (if (f64.gt (global.get $time) (f64.const 64))
      (global.set $time (f64.const 0))
    )
  )
)
