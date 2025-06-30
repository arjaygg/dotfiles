function pomodoro -d "a cli pomodoro"
	while true
		say "Let's go!"
		timer 25m --name Working
		say "Break!"
		notify-send "Time to rest..." -a Pomodoro -c Done 		
		timer 5m --name Break
		notify-send "Let's get back to it" -a Pomodoro -c Work
	end
end
