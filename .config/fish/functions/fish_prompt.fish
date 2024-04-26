function fish_prompt --description 'Write out the prompt'
    eval /bin/powerline-go -modules "user,ssh,cwd,perms,git,jobs,exit,root,newline,time" -error $status -jobs (count (jobs -p))
end
