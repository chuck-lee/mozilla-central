#!/usr/bin/python2.5
#
# Copyright 2010 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the 'License')
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Handlers for New Rich Text Tests"""

__author__ = 'rolandsteiner@google.com (Roland Steiner)'

from google.appengine.api import users
from google.appengine.ext import db
from google.appengine.api import memcache
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template

import django
from django import http
from django import shortcuts

from django.template import add_to_builtins
add_to_builtins('base.custom_filters')

# Shared stuff
from categories import all_test_sets
from base import decorators
from base import util

# common to the RichText2 suite
from categories.richtext2 import common

# tests
from categories.richtext2.tests.apply         import APPLY_TESTS
from categories.richtext2.tests.applyCSS      import APPLY_TESTS_CSS
from categories.richtext2.tests.change        import CHANGE_TESTS
from categories.richtext2.tests.changeCSS     import CHANGE_TESTS_CSS
from categories.richtext2.tests.delete        import DELETE_TESTS
from categories.richtext2.tests.forwarddelete import FORWARDDELETE_TESTS
from categories.richtext2.tests.insert        import INSERT_TESTS
from categories.richtext2.tests.selection     import SELECTION_TESTS
from categories.richtext2.tests.unapply       import UNAPPLY_TESTS
from categories.richtext2.tests.unapplyCSS    import UNAPPLY_TESTS_CSS

from categories.richtext2.tests.querySupported  import QUERYSUPPORTED_TESTS
from categories.richtext2.tests.queryEnabled    import QUERYENABLED_TESTS
from categories.richtext2.tests.queryIndeterm   import QUERYINDETERM_TESTS
from categories.richtext2.tests.queryState      import QUERYSTATE_TESTS, QUERYSTATE_TESTS_CSS
from categories.richtext2.tests.queryValue      import QUERYVALUE_TESTS, QUERYVALUE_TESTS_CSS


def About(request):
  """About page."""
  overview = """These tests cover browers' implementations of 
  <a href="http://blog.whatwg.org/the-road-to-html-5-contenteditable">contenteditable</a>
  for basic rich text formatting commands. Most browser implementations do very
  well at editing the HTML which is generated by their own execCommands. But a
  big problem happens when developers try to make cross-browser web
  applications using contenteditable - most browsers are not able to correctly
  change formatting generated by other browsers. On top of that, most browsers
  allow users to to paste arbitrary HTML from other webpages into a
  contenteditable region, which is even harder for browsers to properly
  format. These tests check how well the execCommand, queryCommandState,
  and queryCommandValue functions work with different types of HTML."""
  return util.About(request, common.CATEGORY, category_title='Rich Text',
                    overview=overview, show_hidden=False)


def RunRichText2Tests(request):
  params = {
    'classes': common.CLASSES,
    'commonIDPrefix': common.TEST_ID_PREFIX,
    'strict': False,
    'suites': [
      SELECTION_TESTS,
      APPLY_TESTS,
      APPLY_TESTS_CSS,
      CHANGE_TESTS,
      CHANGE_TESTS_CSS,
      UNAPPLY_TESTS,
      UNAPPLY_TESTS_CSS,
      DELETE_TESTS,
      FORWARDDELETE_TESTS,
      INSERT_TESTS,

      QUERYSUPPORTED_TESTS,
      QUERYENABLED_TESTS,
      QUERYINDETERM_TESTS,
      QUERYSTATE_TESTS,
      QUERYSTATE_TESTS_CSS,
      QUERYVALUE_TESTS,
      QUERYVALUE_TESTS_CSS
    ]
  }
  return shortcuts.render_to_response('%s/templates/richtext2.html' % common.CATEGORY, params)



