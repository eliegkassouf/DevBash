<h1>DevBash</h1>
<h3>Example of the script in action</h3>
<p>See below for more details!</p>

![alt text](https://raw.githubusercontent.com/eliegkassouf/DevBash/master/example/example.png)

<hr>

<h3>What does this script feature?</h3>
<ol>
  <li>Automatic Homebrew Install (Homebrew is installed if not already).</li>
  <li>Automatic Homebrew package check (verifies that packages are installed. If not they are installed automatically) - Modify the <b>requiredHomebrewPackages</b> array to add your own).</li>
  <li>Automatic Homebrew cask check (verifies that casks are installed. If not they are installed automatically) - Modify the <b>requiredHomebrewCasks</b> array to add your own).</li>
  <li>Automatic Homebrew cask upgrade (needs to be actioned by the user) see the: <b>envE</b> option. -> I will try to automate this in a future updaqte.</li>
  <li>Automatic Postgres setup if package was installed by script (creates default 'postgres' database).</li>
  <li>Automatic Postgres restart if the selected projects requires it.</li>
  <li>Supports multiple projects and provides a prompt for selection and validation for the selected option.</li>
  <li>Supports iTerm new tab/profile launch. See commented out code: <b>#osascript -e 'tell application "iTerm"'</b> and update profile with your own.</li>
  <li>Terminal auto close if not used by other processes (uncomment the last line of the script).</li>
  <li>Easy to edit; don't require Postgres or some other packages? You can make this script your own with a little tweaking. I set it up in a way that anyone can copy it and make it their own even if Homebrew isn't required.</li>
</ol>

<h3>Help</h3>
<ul>
  <li>My computer says I don't have the proper permissions to run this. <br/> <b>Please see</b>: https://apple.stackexchange.com/a/113975</li>  
</ul>
