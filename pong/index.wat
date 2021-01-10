(module
  (global $width (import "env" "width") i32)
  (global $height (import "env" "height") i32)
  (global $fwidth (import "env" "width") f32)
  (global $fheight (import "env" "height") f32)
  (global $input (import "env" "input") (mut i32))
  (memory (export "memory") 1)

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

  (func $clear (local $x i32) (local $y i32)
    (local.set $y (i32.const 0))

    (loop $y_loop
      (local.set $x (i32.const 0))
      (loop $x_loop
        (call $write
          (local.get $x)
          (local.get $y)
          (i32.const 0)
          (i32.const 0)
          (i32.const 0))

        (local.set $x (i32.add (local.get $x) (i32.const 1)))
        (br_if $x_loop (i32.ne (local.get $x) (global.get $width)))
      )

      (local.set $y (i32.add (local.get $y) (i32.const 1)))
      (br_if $y_loop (i32.ne (local.get $y) (global.get $height)))
    )
  )

  (func $court (local $x i32) (local $y i32)
    (local.set $x (i32.div_u (global.get $width) (i32.const 2)))
    (loop $loop
      (call $write
        (local.get $x)
        (local.get $y)
        (i32.const 255)
        (i32.const 255)
        (i32.const 255))

      (local.set $y (i32.add (local.get $y) (i32.const 2)))

      (br_if $loop (i32.le_u (local.get $y) (global.get $height)))
    )

    (call $write
      (i32.const 0)
      (i32.const 0)
      (i32.const 255)
      (i32.const 255)
      (i32.const 255))
    (call $write
      (i32.sub (global.get $width) (i32.const 1))
      (i32.const 0)
      (i32.const 255)
      (i32.const 255)
      (i32.const 255))
    (call $write
      (i32.const 0)
      (i32.sub (global.get $height) (i32.const 1))
      (i32.const 255)
      (i32.const 255)
      (i32.const 255))
    (call $write
      (i32.sub (global.get $width) (i32.const 1))
      (i32.sub (global.get $height) (i32.const 1))
      (i32.const 255)
      (i32.const 255)
      (i32.const 255))
  )

  (global $paddle_height i32 (i32.const 10))

  (func $paddle (param $x i32) (param $y i32)
                (local $yo i32)
    (loop $loop
      (call $write
        (local.get $x)
        (i32.add (local.get $y) (local.get $yo))
        (i32.const 255)
        (i32.const 255)
        (i32.const 255))

      (local.set $yo (i32.add (local.get $yo) (i32.const 1)))

      (br_if $loop (i32.le_u (local.get $yo) (global.get $paddle_height)))
    )
  )

  (global $ball_pos_x (mut f32) (f32.const 0))
  (global $ball_pos_y (mut f32) (f32.const 0))
  (global $ball_vel_x (mut f32) (f32.const 1))
  (global $ball_vel_y (mut f32) (f32.const 0.5))

  (global $player_pos_y (mut i32) (i32.const 0))

  (func $ball
    (global.set $ball_pos_x (f32.add (global.get $ball_pos_x) (global.get $ball_vel_x)))
    (global.set $ball_pos_y (f32.add (global.get $ball_pos_y) (global.get $ball_vel_y)))

    (if (f32.le (global.get $ball_pos_x) (f32.const 1.0))
      (if (i32.and
            (i32.ge_u (i32.trunc_f32_u (global.get $ball_pos_y)) (global.get $player_pos_y))
            (i32.le_u (i32.trunc_f32_u (global.get $ball_pos_y)) (i32.add (global.get $player_pos_y) (global.get $paddle_height))))
        (then
          (global.set $ball_vel_x (f32.mul (global.get $ball_vel_x) (f32.const -1.0)))
          (if (i32.ge_u
                (i32.trunc_f32_u (global.get $ball_pos_y))
                (i32.add
                  (global.get $player_pos_y)
                  (i32.div_u (global.get $paddle_height) (i32.const 2))))
            (then
              (global.set $ball_vel_y (f32.const 0.5))
            )
            (else
              (global.set $ball_vel_y (f32.const -0.5))
            ))
        )
        (else
          (global.set $ball_pos_x (f32.sub (global.get $fwidth) (f32.const 3)))
          (global.set $ball_pos_y (f32.convert_i32_u (i32.add (global.get $player_pos_y) (i32.div_u (global.get $paddle_height) (i32.const 2)))))
          (global.set $ball_vel_x (f32.const -1.0))
          (global.set $ball_vel_y (f32.const 0))
        )))

    (if (f32.ge
          (global.get $ball_pos_x)
          (f32.sub (global.get $fwidth) (f32.const 2)))
      (if (i32.and
            (i32.ge_u (i32.trunc_f32_u (global.get $ball_pos_y)) (global.get $player_pos_y))
            (i32.le_u (i32.trunc_f32_u (global.get $ball_pos_y)) (i32.add (global.get $player_pos_y) (global.get $paddle_height))))
        (then
          (global.set $ball_vel_x (f32.mul (global.get $ball_vel_x) (f32.const -1)))
          (if (i32.ge_u
                (i32.trunc_f32_u (global.get $ball_pos_y))
                (i32.add
                  (global.get $player_pos_y)
                  (i32.div_u (global.get $paddle_height) (i32.const 2))))
            (then
              (global.set $ball_vel_y (f32.const 0.5))
            )
            (else
              (global.set $ball_vel_y (f32.const -0.5))
            ))
        )
        (else
          (global.set $ball_pos_x (f32.const 2))
          (global.set $ball_pos_y (f32.convert_i32_u (i32.add (global.get $player_pos_y) (i32.div_u (global.get $paddle_height) (i32.const 2)))))
          (global.set $ball_vel_x (f32.const 1))
          (global.set $ball_vel_y (f32.const 0))
        )))

    (if (i32.and
          (f32.le (global.get $ball_vel_y) (f32.const 0))
          (f32.le (global.get $ball_pos_y) (f32.const 0.5)))
      (global.set $ball_vel_y (f32.mul (global.get $ball_vel_y) (f32.const -1)))
    )
    (if (i32.and
          (f32.ge (global.get $ball_vel_y) (f32.const 0))
          (f32.ge (global.get $ball_pos_y) (f32.sub (global.get $fheight) (f32.const 1))))
      (global.set $ball_vel_y (f32.mul (global.get $ball_vel_y) (f32.const -1)))
    )

    (call $write
      (i32.trunc_f32_u (global.get $ball_pos_x))
      (i32.trunc_f32_u (global.get $ball_pos_y))
      (i32.const 255)
      (i32.const 255)
      (i32.const 255))
  )

  (func $start
    global.get $height
    i32.const 2
    i32.div_u
    global.get $paddle_height
    i32.const 2
    i32.div_u
    i32.sub
    global.set $player_pos_y
  )
  (start $start)

  (func (export "draw")
    call $clear

    (if (i32.and
          (i32.ne (global.get $player_pos_y) (i32.const 0))
          (i32.and (global.get $input) (i32.const 1)))
      (global.set $player_pos_y (i32.sub (global.get $player_pos_y) (i32.const 1)))
    )

    (if (i32.and
          (i32.lt_u
            (global.get $player_pos_y)
            (i32.sub
              (global.get $height)
              (i32.add
                (global.get $paddle_height)
                (i32.const 1))))
          (i32.eq
            (i32.and (global.get $input) (i32.const 2))
            (i32.const 2)))
      (global.set $player_pos_y (i32.add (global.get $player_pos_y) (i32.const 1)))
    )

    (call $court)
    (call $ball)
    (call $paddle (i32.sub (global.get $width) (i32.const 2)) (global.get $player_pos_y))
    (call $paddle (i32.const 1) (global.get $player_pos_y))
  )
)
