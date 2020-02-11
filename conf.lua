function love.conf(t)
	io.stdout:setvbuf("no")

	t.identity = "And yet it hurt"
	t.version = "11.3"
	t.console = true

	t.modules.timer = true

	-- lol
	t.modules.event = false
	t.modules.thread = false
	t.modules.audio = false
	t.modules.graphics = false
	t.modules.image = false
	t.modules.joystick = false
	t.modules.keyboard = false
	t.modules.math = false
	t.modules.mouse = false
	t.modules.physics = false
	t.modules.sound = false
	t.modules.system = false
	t.modules.window = false
end