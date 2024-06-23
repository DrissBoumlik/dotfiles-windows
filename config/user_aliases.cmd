

rem =========================================== CUSTOM ALIASES ===========================================
-cd=cd - $*
lsa=ls -a --show-control-chars -F --color $*
lsall=ls -latsh $*
seeu=exit
quit=exit
:q=exit
exp=explorer $*
e=explorer $*
rmrf=rm -rf $*
bzsh=bash -c zsh
bsh=C:\Cmder\vendor\conemu-maximus5\..\git-for-windows\bin\bash $*
a:r=alias /reload
w:env=%windir%\System32\SystemPropertiesAdvanced.exe
env:r=RefreshEnv.cmd
rem =================== PLUGINS ============
historyf="C:\Cmder\vendor\clink\clink_x64.exe" history | fzf $*
historyf2="C:\Cmder\vendor\clink\clink_x64.exe" history | fzf --exact --multi --border=rounded --color=border:7,marker:1,pointer:5,header:6,info:6,prompt:6,spinner:4 --reverse --tac --header="______________________" --cycle --pointer=">>" --marker=">>"
aliasf=alias | fzf $*
zadd=z --add $*


rem ===============================  GIT  ===============================
gs=git status $*
ga=git add $*
ga.=git add .
gaa=git add . $*
glg=git log $*
glp=git log-pretty $*
glp2=git log-pretty2 $*
glp3=git log-pretty3 $*
glf=git log-pretty | tail -n $*
gll=git log-pretty -n $*
gl=git log --oneline --all --graph --decorate  $*
gc=git commit $*
gd=git diff $*
gcm=git commit -m "$*"
wip=git add . && git commit -m "$* (wip)"  
gpl=git pull $*
gps=git push $*
gplgit=git pull github master $*
gpsbit=git push bitbucket master $*
gpsgit=git push github master $*
grv=git remote -v $*
gplbit=git pull bitbucket master $*
gplom=git pull origin master $*
gpsom=git push origin master $*
gi=git init $*
gck=git checkout $*
gckp=git checkout @{-$*}
gm=git merge $*
gb=git branch $*
gcl=git clone $*
grfl=git reflog $*
gplo=git pull origin $*
gpso=git push origin $*
gr=git reset $*
grh=git reset --hard $*
nah=git reset --hard && git clean -df
grhh=git reset --hard HEAD $*
grs=git reset --soft $*
grm=git rm $*
gmg=git merge $*  

rem ===============================  NPM  ===============================
nu=npm update $*
ni=npm install $*
nrs=npm run serve $*
nrd=npm run dev $*
nrb=npm run build $*
nrw=npm run watch $*
nrp=npm run prod $*
nv=nvm current  
ncc=npm cache clean --force $* && npm cache verify --force $*

tscv=tsc --version  

rem ===============================  ANGULAR  ===============================
ngv=ng version $*
ngs=ng serve $*
ngsp=ng serve --port $*
ngsnr=ng serve --no-live-reload $*
ngsa=ng serve --aot $*
ngsanr=ng serve --aot --no-live-reload $*
nggc=ng generate component $*
nggs=ng generate service $*
nggd=ng generate directive $*
nggm=ng generate module $*
nggp=ng generate pipe $*
nggg=ng generate guard $*

rem ===============================  TESTING  ===============================
pest=.\vendor\bin\pest $*  
punitx=.\vendor\bin\phpunit --testdox $*  
_jest=node "node_modules\jest\bin\jest.js" $*  
_mocha=node "node_modules\mocha\bin\mocha.js" $*  

rem ===============================  ENV  ===============================
setphp=setx php_now "%$1%" /m && RefreshEnv.cmd
setpy=setx python_now "%$1%" /m && RefreshEnv.cmd 
zi=z -I $*
jsc=tsc $1.ts $* && node $1.js


rem ===============================  PHP (TOOLS)  ===============================
php56="D:\Code\env-setup\php\php-5.6.9-Win32-VC11-x64\php" $*
php7="D:\Code\env-setup\php\php-7.0.9-Win32-VC14-x64\php" $*
php72="D:\Code\env-setup\php\php-7.2.9-Win32-VC15-x64\php" $*
php74="D:\Code\env-setup\php\php-7.4.9-Win32-vc15-x64\php" $* 
phpxmp="C:\xampp-8.1\php\php.exe" $* 
php8="D:\Code\env-setup\php\php-8.0.9-Win32-vs16-x64\php" $*
php81="D:\Code\env-setup\php\php-8.1.9-Win32-vs16-x64\php" $*
php82="D:\Code\env-setup\php\php-8.2.9-Win32-vs16-x64\php" $*
pv=php -v
phpcs=php "D:\Code\env-setup\tools\phpcs.phar" $*
phpcbf=php "D:\Code\env-setup\tools\phpcbf.phar" $*
phpmd=php "D:\Code\env-setup\tools\phpmd.phar" $*
phpstan=php "D:\Code\env-setup\tools\phpstan.phar" $*
phpfixer=php "D:\Code\env-setup\tools\php-cs-fixer-v3.phar" $*
punit=.\vendor\bin\phpunit $*

rem ===============================  PYTHON  ===============================
phpnow=echo %php_now%
pythonnow=echo %python_now%

rem ===============================  COMPOSER  ==============================
ci=composer install $*
cu=composer update $*
cmpref=composer dump-autoload $*
ci1=composer1 install $*
cu1=composer1 update $*
cmpref1=composer1 dump-autoload $*

rem ===============================  LARAVEL  ===============================
pamk=php artisan make:$*
pav=php artisan --version $*
pam=php artisan migrate $*
pas=php artisan serve $*
pa=php artisan $*
pamfs=php artisan migrate:fresh --seed $*
pamfspi=php artisan migrate:fresh --seed $t php artisan passport:install --force $*
parl=php artisan route:list $*
pamf=php artisan migrate:fresh $*
pamkmm=php artisan make:model $1 -m
pamkmmc=php artisan make:model $1 -m -c
pamkmmcr=php artisan make:model $1 -m -c -r
pash=php artisan serve --host $*
pasp=php artisan serve --port $*
pasph=php artisan serve --port $1 --host $2
pashp=php artisan serve --host $1 --port $2
pamkmdl=php artisan make:model $*
pamkc=php artisan make:controller $*Controller
pamkmg=php artisan make:migration create_$*_table
pamkcr=php artisan make:controller $*Controller -r
pams=php artisan migrate --seed $*
pamkr=php artisan make:resource $*Resource
pamkrc=php artisan make:resource $*Collection
pamkrq=php artisan make:request $*Request
pamkf=php artisan make:factory $1Factory --model=$1
pamkfm=php artisan make:factory $1Factory --model=$2
pat=php artisan tinker $*
padbs=php artisan db:seed $*
pamks=php artisan make:seeder $1sSeeder
pamkfsd=php artisan make:factory $1Factory --model=$1 $t php artisan make:seeder $1sSeeder
pakg=php artisan key:generate $*
pamkcmp=php artisan make:component $*
pamkall=php artisan make:model $1 -m -c -f $t php artisan make:seeder $1sSeeder
pamkallmdl=php artisan make:model $1/$2 -m -c -f $t php artisan make:seeder $2sSeeder
pamkallmdlsd=php artisan make:model $1/$2 -m -c -f $t php artisan make:seeder $3sSeeder
pamkallsd=php artisan make:model $1 -m -c -f $t php artisan make:seeder $2sSeeder
rfl=composer dumpautoload $t php artisan optimize $t php artisan cache:clear $t php artisan view:clear
rfl1=composer1 dumpautoload $t php artisan cache:clear $t php artisan view:clear $t php artisan config:clear $t php artisan route:clear  
pamkallr=php artisan make:model $1 -m -c -f $t php artisan make:seeder $1sSeeder $t php artisan make:resource $1Resource
rld=git pull origin master $t composer dumpautoload $t php artisan optimize $t php artisan cache:clear $t php artisan view:clear $t npm run dev $*
rld1=git pull origin master $t composer1 dumpautoload $t php artisan optimize $t php artisan cache:clear $t php artisan view:clear $t npm run dev $*
pamkj=php artisan make:job $*Job
pamke=php artisan make:event $*Event
parc=php artisan route:clear  
pavc=php artisan view:clear  
pacc=php artisan cache:clear  
pacgc=php artisan config:clear  
pacgcc=php artisan config:cache  
pao=php artisan optimize  
pasl=php artisan storage:link  



rem ===============================  SVN  ===============================
ss=svn status $*
sp=svn update $*

rem ===============================  DOCKER  ===============================
dk=docker $*
dkps=docker ps $*
dkpsa=docker ps -a $*
dkll=docker kill $*
dkrmcn=docker container rm $*
dkrmim=docker image rm $*
dkimls=docker image ls $*
dksp=docker system prune $*
dkspa=docker system prune -a $*
dkim=docker image $*
dkims=docker images $*
dkimsa=docker images -a $*
dkc=docker-compose $*
dcx=docker-compose exec $*  
dcxpunit=docker-compose exec $1 ./vendor/bin/phpunit $2  
dcxpest=docker-compose exec $1 ./vendor/bin/pest $2  
dcxpatest=docker-compose exec $1 php artisan test $2  

rem ===============================  EXE  ===============================
npp="C:\Program Files\Notepad++\notepad++.exe" $*
code.=code . $*
cpy=echo $1|clip && $1|clip

rem ===============================  CD..  ===============================
_desktop=cd "C:\Users\cartouche\_desktop" && C:
desktop=cd "C:\Users\cartouche\Desktop\" && C:
.ssh=cd "C:\Users\cartouche\.ssh\" && C:  
bot=cd "D:\Code\Personal\Projects\teabot-py" && D:
learn=cd "D:\Code\Personal\Learning" && D:
books=cd "D:\Books" && D:
community=cd "D:\Code\Personal\community" && D:
projects=cd "D:\Code\Personal\projects" && D:
db=cd "D:\Code\Personal\Projects\drissboumlik.com\drissboumlik.com_src\" && D:
tc=cd "D:\Code\Personal\Projects\teacode.ma\teacode.ma_src\" && D:
phpdir=cd "D:\Code\env-setup\php\" && D:
envdir=cd "D:\Code\env-setup\" && D:
home=cd "C:\Users\cartouche\" && C:
work=cd "D:\Code\Work\" && D:
mine=cd "D:\Code\Personal\" && D:
bb=cd "D:\Code\Work\Free\b2b\b2b_src" && D:
proconnect=cd "D:\Code\Work\Free\proconnect\proconnect_src\" && D:

rem ===============================  SSH  ===============================
tchost=ssh -p 65002 u110977776@212.107.17.137   
rlab=ssh kjr@81.192.187.150 $*
dbhost=ssh -p 65002 u197029946@31.170.164.50  
aws=ssh -i ~/.ssh/Laravel-Test-1.pem ubuntu@3.142.52.151  
olivaws=ssh driss@ec2-172-31-7-107.us-east-2.compute.amazonaws.com  

rem ===============================  SCRIPTS  ===============================
patchbb=sh "/d/Code/Work/Free/Generate-Patch/build.sh" $*   

