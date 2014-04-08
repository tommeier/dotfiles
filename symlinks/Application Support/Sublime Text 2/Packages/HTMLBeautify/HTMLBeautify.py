#!/usr/bin/python
#
# HTMLBeautify v0.8
# Sublime Text (2 & 3)
# (Inspired by fhtml.pl by John Watson)
# by Ross A. Reyman
# 2 April 2014
# url:			http://reyman.name/
# e-mail:		ross[at]reyman[dot]name
#
# REVISION HISTORY:
#  *cbr 04/14 - compile the regexs for speed
#				unindent properly when closing tags are stacked on the same line (mis-matched tags will probably break this)

import sublime, sublime_plugin, re

class HtmlBeautifyCommand(sublime_plugin.TextCommand):
		def run(self, edit):

			# this file contains the tags that will be indented/unindented, etc.
			settings = sublime.load_settings('HTMLBeautify.sublime-settings')

			# the contents of these tags will not be indented
			ignored_tag_opening 		= settings.get('ignored_tag_opening')
			ignored_tag_closing 		= settings.get('ignored_tag_closing')

			ignored_tag_opening_re 		= re.compile(ignored_tag_opening, re.IGNORECASE)
			ignored_tag_closing_re 		= re.compile(ignored_tag_closing, re.IGNORECASE)

			# the content of these tags will be indented
			tag_indent 					= settings.get('tag_indent')
			tag_indent_re				= re.compile(tag_indent, re.IGNORECASE)

			# these tags will be un-indented
			tag_unindent 				= settings.get('tag_unindent')
			tag_unindent_re 			= re.compile(tag_unindent, re.IGNORECASE)

			# these tags may occur inline and should not indent/unindent
			tag_pos_inline 				= settings.get('tag_pos_inline')
			tag_pos_inline_re 			= re.compile(tag_pos_inline, re.IGNORECASE)

			# these tags use raw code and should flatten to col1
			# tabs will be removed inside these tags! use spaces for spacing if needed!
			tag_raw_flat_opening		= "<pre"
			tag_raw_flat_closing		= "</pre"
			tag_raw_flat_opening_re 	= re.compile(tag_raw_flat_opening)
			tag_raw_flat_closing_re 	= re.compile(tag_raw_flat_closing)

			# determine if applying to a selection or applying to the whole document
			if self.view.sel()[0].empty():
				# nothing selected: process the entire file
				region = sublime.Region(0, self.view.size())
				sublime.status_message('Beautifying Entire File')
				rawcode = self.view.substr(region)
				# print region
			else:
				# process only selected region
				region = self.view.line(self.view.sel()[0])
				sublime.status_message('Beautifying Selection Only')
				rawcode = self.view.substr(self.view.sel()[0])
				# print region

			# print rawcode

			# remove leading and trailing white space
			rawcode = rawcode.strip()
			# print rawcode

			# put each line into a list
			rawcode_list = re.split('\n', rawcode)
			# print rawcode_list

			# cycle through each list item (line of rawcode_list)
			rawcode_flat = ""
			is_block_ignored = False
			is_block_raw = False

			for item in rawcode_list:
				# print item.strip()
				# remove extra "spacer" lines
				if item == "":
					continue
				# ignore raw code
				if tag_raw_flat_closing_re.search(item):
					tmp = item.strip()
					is_block_raw = False
				elif tag_raw_flat_opening_re.search(item):
					tmp = item.strip()
					is_block_raw = True
				# find ignored blocks and retain indentation, otherwise: strip whitespace
				if ignored_tag_closing_re.search(item):
					tmp = item.strip()
					is_block_ignored = False
				elif ignored_tag_opening_re.search(item):
					# count tabs used in ignored tags (for use later)
					ignored_block_tab_count = item.count('\t')
					tmp = item.strip()
					is_block_ignored = True
				# not filtered so just output it
				else:
					if is_block_raw == True:
						# remove tabs from raw_flat content
						tmp = re.sub('\t', '', item)
					elif is_block_ignored == True:
						tab_count = item.count('\t') - ignored_block_tab_count
						tmp = '\t' * tab_count + item.strip()
					else:
						tmp = item.strip()

				rawcode_flat = rawcode_flat + tmp + '\n'

			# print rawcode_flat

			# put each line into a list (again)
			rawcode_flat_list = re.split('\n', rawcode_flat)
			# print rawcode_flat_list

			# cycle through each list item (line of rawode_flat_list) again - this time: add indentation!
			beautified_code = ""

			indent_level = 0
			is_block_ignored = False
			is_block_raw = False

			for item in rawcode_flat_list:
				# match_end_pos denotes where we should start looking for dangling closing tags
				match_end_pos = 0

				# if a one-line, inline tag, just process it
				if tag_pos_inline_re.search(item):
					match_end_pos = tag_pos_inline_re.search(item).end()
					tmp = ("\t" * indent_level) + item
				# if unindent, move left
				elif tag_unindent_re.search(item):
					match_end_pos = tag_unindent_re.search(item).end()
					indent_level = indent_level - 1
					tmp = ("\t" * indent_level) + item
				# if indent, move right
				elif tag_indent_re.search(item):
					match_end_pos = tag_indent_re.search(item).end()
					indent_level = indent_level + 1
					tmp = ("\t" * indent_level) + item
				# if raw, flatten! no indenting!
				elif tag_raw_flat_opening_re.search(item):
					is_block_raw = True
					tmp = item
				elif tag_raw_flat_closing_re.search(item):
					is_block_raw = False
					tmp = item
				else:
					if is_block_raw == True:
						tmp = item
					# otherwise, just leave same level
					else:
						tmp = ("\t" * indent_level) + item

				# we don't want to loop on this line forever
				if match_end_pos == 0:
					match_end_pos = len(item)
				beautified_code = beautified_code + tmp + '\n'

				# check for lingering closing tags
				while tag_unindent_re.search(item, match_end_pos) and indent_level > 0:
					# get the end for the next closing tag
					match_end_pos = tag_unindent_re.search(item, match_end_pos).end()
					indent_level = indent_level - 1

			# remove leading and trailing white space
			beautified_code = beautified_code.strip()

			# print beautified_code

			# replace the code in Sublime Text
			self.view.replace(edit, region, beautified_code)

			# done
