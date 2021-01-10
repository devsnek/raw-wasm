(module
  (global $width (import "env" "width") i32)
  (global $height (import "env" "height") i32)
  (global $fwidth (import "env" "width") f64)
  (global $fheight (import "env" "height") f64)
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

  (func $a (param $x i32) (param $y i32) (result i32)
    global.get $time

    local.get $y
    local.get $x
    i32.or
    f64.convert_i32_u

    f64.mul

    i32.trunc_f64_u
  )

  (func (export "draw")
        (local $x i32)
        (local $y i32)
    (local.set $y (i32.const 0))

    (loop $y_loop
      (local.set $x (i32.const 0))
      (loop $x_loop
        (call $write
          (local.get $x)
          (local.get $y)
          (i32.trunc_f64_u
            (f64.mul
              (f64.convert_i32_u (local.get $x))
              (f64.div (f64.const 255) (global.get $fwidth))))
          (call $a (local.get $x) (local.get $y))
          (i32.trunc_f64_u
            (f64.mul
              (f64.convert_i32_u (local.get $y))
              (f64.div (f64.const 255) (global.get $fwidth))))
        )

        (local.set $x (i32.add (local.get $x) (i32.const 1)))
        (br_if $x_loop (i32.ne (local.get $x) (global.get $width)))
      )

      (local.set $y (i32.add (local.get $y) (i32.const 1)))
      (br_if $y_loop (i32.ne (local.get $y) (global.get $height)))
    )

    (global.set $time (f64.add (global.get $time) (f64.const 0.05)))
    (if (f64.gt (global.get $time) (f64.const 128))
      (global.set $time (f64.const 0))
    )
  )
)
