# scratch - create/enter directories in ~/scratch
# format: MM-DD@HH.MM
# usage: scratch [-n|--new] [-l|--latest] [-r|--recent N]
# no args - enters today's most latest dir, or prompts to create one
# -n: creates new scratch dir
# -l: enters most recent dir
# -r N: enters Nth most recent dir (0-indexed)

function scratch
   set -l base_dir ~/scratch
   set -l current_date (date '+%m-%d')
   set -l current_time (date '+%H.%M')
   set -l new_dir "$base_dir/$current_date@$current_time"

   mkdir -p $base_dir

   if test (count $argv) -gt 0
       switch $argv[1]
           case "--new" "-n"
               mkdir -p $new_dir
               cd $new_dir
               return
           case "--latest" "-l"
               if test (count $argv) -gt 1
                   echo "Error: --latest doesn't accept additional arguments"
                   return 1
               end
               set -l dirs (find $base_dir -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
               if test (count $dirs) -gt 0
                   set -l latest_dir (string join \n $dirs | sort -r | head -n1)
                   cd $latest_dir
                   return
               end
               echo "No scratch directories found"
               return 1
           case "--recent" "-r"
               if test (count $argv) -ne 2
                   echo "Error: --recent requires a number argument"
                   return 1
               end
               if not string match -qr '^[0-9]+$' $argv[2]
                   echo "Error: --recent argument must be a number"
                   return 1
               end
               set -l dirs (find $base_dir -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
               if test (count $dirs) -gt 0
                   set -l target_dir (string join \n $dirs | sort -r | sed -n (math $argv[2] + 1)"p")
                   if test -n "$target_dir"
                       cd $target_dir
                       return
                   end
                   echo "No scratch directory at index $argv[2]"
                   return 1
               end
               echo "No scratch directories found"
               return 1
       end
   end

   # if a scratch dir exists from today, use it; otherwise prompt for new one
   set -l dirs (find $base_dir -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
   if test (count $dirs) -gt 0
       set -l latest_dir (string join \n $dirs | sort -r | head -n1)
       set -l latest_date (string match -r '\d{2}-\d{2}' $latest_dir)

       if test "$latest_date" = "$current_date"
           cd $latest_dir
           return
       end
   end

   read -l -P "Create new scratch directory for today? [Y/n] " confirm
   if test -z "$confirm" -o "$confirm" = "y" -o "$confirm" = "Y"
       mkdir -p $new_dir
       cd $new_dir
   end
end
