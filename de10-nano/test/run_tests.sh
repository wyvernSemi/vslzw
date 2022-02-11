###################################################################
# Platform regression test script
#
# Copyright (c) 2022 Simon Southwell
#
# This code is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# The code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this code. If not, see <http://www.gnu.org/licenses/>.
#
###################################################################

#
# Remove key directories and files to ensure a clean build and run
#
rm -f test.log

#########################################
# Run tests from here
#########################################



#########################################

#
# Display the test log
#
grep "Test exit" test.log
