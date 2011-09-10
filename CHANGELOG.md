## 0.2.7 (2011-09-11)

* acceptance_ratio bug fixed

## 0.2.6 (2011-09-09)

* cf line inspect cmd changed to cf line details because the inspect method is the Ruby's declared method
* acceptance_ratio parameter added in gem for tournament station
* while creating a line which has production runs was giving inappropriate messages. its fixed.
* sample line input file now has our own hosted files

## 0.2.5 (2011-09-01)

* Broken url after doing production run on date 01 - 09 day. Fixed
* Public true/false value is always set to true when line created via CLI. Fixed
* Yaml validator modified for worker's setting attributes, if worker_type is robot.

## 0.2.4 (2011-08-31)

* valid_type: text removed from the sample line generated line.yml file

## 0.2.3 (2011-08-30)

* Add a new command in CLI, cf production delete --run-title=your-run-title to delete the production run
* The same is added in Gem
* If no valid_type is sent in input_formats, it will be created. Before, it was the mandatory.

## 0.2.2 (2011-08-29)

* Add a new command in CLI, cf whoami to show the current logged in credentials
* Psych::SyntaxError and Syck::SyntaxError exceptions caught once again to show some intuitive error instead of scary backtrace
* Tested when adding units for blank/no data
* Output format bug fixed in GEM
* Fixed miscellaneous bugs 

## 0.2.1 (2011-08-26)

* Fixed the bug of creating multiple output formats for a line. Issue #352

## 0.2.0 (2011-08-26)

* Line creation when doing production and if the line is not created is now removed. Fixed #283

## 0.1.22 (2011-08-26)

* Fixed #317
* Fixed #156
* Fixed #328
* Store the account name and email ad while cf login
* For runs and lines listing, :page => 'all' added to return all the records #321
* Inserting units to existing production run #310

## 0.1.21 (2011-08-25)

* Line listing with pagination with custom flags
* cf login now stores account_name and email as well
* Fixed the line listing issue

## 0.1.20 (2011-08-24)

* Fixed Line listing and deletion issue

## 0.1.19 (2011-08-23)

* Feature: Introduced new cli command: cf line inspect [-l=line_title]
* Bugfix:  Line listing when there are not any lines
* Improved Getting Started documentation or wiki at https://github.com/sprout/cloudfactory_ruby/wiki/Getting-Started

## 0.1.18 (2011-08-22)

* Fixed the active_support version dependency when used with rails 3.1
* CF::Line.inspect method modified according to new changes in API
* Error handling in CLI if source folder not found for custom_task_form
