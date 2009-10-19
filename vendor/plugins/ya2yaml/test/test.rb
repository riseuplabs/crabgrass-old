#!/usr/bin/env ruby

# $Id: test.rb,v 1.4 2007-01-19 20:41:37+09 funai Exp funai $

$: << (File.dirname(__FILE__) + '/../lib')

Dir.chdir(File.dirname(__FILE__))

$KCODE = 'UTF8'
require 'ya2yaml'

require 'yaml'
require 'test/unit'

class TC_Ya2YAML < Test::Unit::TestCase

	@@struct_klass = Struct::new('Foo',:bar,:buz)
	class Moo
		attr_accessor :val1,:val2
		def initialize(val1,val2)
			@val1 = val1
			@val2 = val2
		end
		def ==(k) 
			(k.class == self.class) &&
			(k.val1 == self.val1) &&
			(k.val2 == self.val2)
		end 
	end
	puts "test may take minutes. please wait.\n"

	def setup
		@text = ''
		@gif  = ''
		File.open('./t.yaml','r') {|f| @text = f.read}
		File.open('./t.gif','r') {|f| @gif = f.read}

		@struct = @@struct_klass.new('barbarbar',@@struct_klass.new('baaaar',12345))
		@klass  = Moo.new('boobooboo',Time.new())
	end

	def test_options
		[
			[
				{},
				"--- \n- \"\\u0086\"\n- |-\n    a\xe2\x80\xa8    b\xe2\x80\xa9    c\n- |4-\n     abc\n    xyz\n",
			],
			[
				{:indent_size => 4},
				"--- \n- \"\\u0086\"\n- |-\n        a\xe2\x80\xa8        b\xe2\x80\xa9        c\n- |8-\n         abc\n        xyz\n",
			],
			[
				{:minimum_block_length => 16},
				"--- \n- \"\\u0086\"\n- \"a\\Lb\\Pc\"\n- \" abc\\nxyz\"\n",
			],
#			[
#				{:emit_c_document_end => true},
#				"--- \n- \"\\u0086\"\n- |-\n    a\xe2\x80\xa8    b\xe2\x80\xa9    c\n- |4-\n     abc\n    xyz\n...\n",
#			],
			[
				{:printable_with_syck => true},
				"--- \n- \"\\u0086\"\n- |-\n    a\xe2\x80\xa8    b\xe2\x80\xa9    c\n- \" abc\\n\\\n    xyz\"\n",
			],
			[
				{:escape_b_specific => true},
				"--- \n- \"\\u0086\"\n- \"a\\Lb\\Pc\"\n- |4-\n     abc\n    xyz\n",
			],
			[
				{:escape_as_utf8 => true},
				"--- \n- \"\\xc2\\x86\"\n- |-\n    a\xe2\x80\xa8    b\xe2\x80\xa9    c\n- |4-\n     abc\n    xyz\n",
			],
			[
				{:syck_compatible => true},
				"--- \n- \"\\xc2\\x86\"\n- \"a\\xe2\\x80\\xa8b\\xe2\\x80\\xa9c\"\n- \" abc\\n\\\n    xyz\"\n",
			],
		].each {|opt,yaml|
			y = ["\xc2\x86","a\xe2\x80\xa8b\xe2\x80\xa9c"," abc\nxyz"].ya2yaml(opt)
#			puts y

			assert_equal(y,yaml)
		}
	end

	def test_hash_order
		[
			[
				nil,
				"--- \na: 1\nb: 2\nc: 3\n",
			],
			[
				[],
				"--- \na: 1\nb: 2\nc: 3\n",
			],
			[
				['c','b','a'],
				"--- \nc: 3\nb: 2\na: 1\n",
			],
			[
				['b'],
				"--- \nb: 2\na: 1\nc: 3\n",
			],
		].each {|hash_order,yaml|
			y = {
				'a' => 1,
				'c' => 3,
				'b' => 2,
			}.ya2yaml(
				:hash_order => hash_order
			)
#			p y
			assert_equal(y,yaml)
		}
	end

	def test_normalize_line_breaks
		[
			["\n\n\n\n",          "--- \"\\n\\n\\n\\n\"\n",],
			["\r\n\r\n\r\n",      "--- \"\\n\\n\\n\"\n",],
			["\r\n\n\n",          "--- \"\\n\\n\\n\"\n",],
			["\n\r\n\n",          "--- \"\\n\\n\\n\"\n",],
			["\n\n\r\n",          "--- \"\\n\\n\\n\"\n",],
			["\n\n\n\r",          "--- \"\\n\\n\\n\\n\"\n",],
			["\r\r\n\r",          "--- \"\\n\\n\\n\"\n",],
			["\r\r\r\r",          "--- \"\\n\\n\\n\\n\"\n",],
			["\r\xc2\x85\r\n",    "--- \"\\n\\n\\n\"\n",],
			["\r\xe2\x80\xa8\r\n","--- \"\\n\\L\\n\"\n",],
			["\r\xe2\x80\xa9\r\n","--- \"\\n\\P\\n\"\n",],
		].each {|src,yaml|
			y = src.ya2yaml(
				:minimum_block_length => 16
			)
#			p y
			assert_equal(y,yaml)
		}
	end

	def test_structs
		[
			[Struct.new('Hoge',:foo).new(123),"--- !ruby/struct:Hoge \n  foo: 123\n",],
			[Struct.new(:foo).new(123),       "--- !ruby/struct: \n  foo: 123\n",],
		].each {|src,yaml|
			y = src.ya2yaml()
			assert_equal(y,yaml)
		}
	end

	def test_roundtrip_single_byte_char
		 ("\x00".."\x7f").each {|c|
			y = c.ya2yaml()
#			puts y
			r = YAML.load(y)
			assert_equal((c == "\r" ? "\n" : c),r) # "\r" is normalized as "\n".
		}
	end

	def test_roundtrip_multi_byte_char
		[
			0x80,
			0x85,
			0xa0,
			0x07ff,
			0x0800,
			0x0fff,
			0x1000,
			0x2028,
			0x2029,
			0xcfff,
			0xd000,
			0xd7ff,
			0xe000,
			0xfffd,
			0x10000,
			0x3ffff,
			0x40000,
			0xfffff,
			0x100000,
			0x10ffff,
		].each {|ucs_code|
			[-1,0,1].each {|ofs|
				(c = [ucs_code + ofs].pack('U')) rescue next
				c_hex = c.unpack('H8')
				y = c.ya2yaml(
					:escape_b_specific => true,
					:escape_as_utf8    => true
				)
#				puts y
				r = YAML.load(y)
				assert_equal(
					[c_hex,(c =~ /\xc2\x85/u ? "\n" : c)],
					[c_hex,r]
				) # "\N" is normalized as "\n".
			}
		}
	end

	def test_roundtrip_ambiguous_string
		 [
		 	'true',
			 'false',
			 'TRUE',
			 'FALSE',
			 'Y',
			 'N',
			 'y',
			 'n',
			 'on',
			 'off',
			 true,
			 false,
			 '0b0101',
			 '-0b0101',
			 0b0101,
			 -0b0101,
			 '031',
			 '-031',
			 031,
			 -031,
			 '123.001e-1',
			 '123.01',
			 '123',
			 123.001e-1,
			 123.01,
			 123,
			 '-123.001e-1',
			 '-123.01',
			 '-123',
			 -123.001e-1,
			 -123.01,
			 -123,
			 'INF',
			 'inf',
			 'NaN',
			 'nan',
			 '0xfe2a',
			 '-0xfe2a',
			 0xfe2a,
			 -0xfe2a,
			 '1:23:32.0200',
			 '1:23:32',
			 '-1:23:32.0200',
			 '-1:23:32',
			 '<<',
			 '~',
			 'null',
			 'nUll',
			 'Null',
			 'NULL',
			 '',
			 nil,
			 '2006-09-12',
			 '2006-09-11T17:28:07Z',
			 '2006-09-11T17:28:07+09:00',
			 '2006-09-11 17:28:07.662694 +09:00',
			 '=',
		 ].each {|c|
		 	['','hoge'].each {|ext|
			 	src = c.class == String ? (c + ext) : c
				y = src.ya2yaml(
					:escape_as_utf8 => true
				)
#				puts y
				r = YAML.load(y)
				assert_equal(src,r)
			}
		}
	end

	def test_roundtrip_string
		chars = "aあ\t\-\?,\[\{\#&\*!\|>'\"\%\@\`.\\ \n\xc2\xa0\xe2\x80\xa8".split('')
		
		chars.each {|i|
			chars.each {|j|
				chars.each {|k|
					chars.each {|l|
						src = i + j + k + l
						y =  src.ya2yaml(
							:printable_with_syck => true,
							:escape_b_specific   => true,
							:escape_as_utf8      => true
						)
#						puts y
						r = YAML.load(y)
						assert_equal(src,r)
					}
				}
			}
		}
	end

	def test_roundtrip_types
		objects = [
			[],
			[1],
			{},
			{'foo' => 'bar'},
			nil,
			'hoge',
			"abc\nxyz\n",
			"\xff\xff",
			true,
			false,
			1000,
			1000.1,
			-1000,
			-1000.1,
			Date.today(),
			Time.new(),
			:foo,
			1..10,
			/abc\nxyz/i,
			@struct,
			@klass,
		]

		objects.each {|obj|
			src = case obj.class.to_s
				when 'Array'
					(obj.length) == 0 ? [] : objects
				when 'Hash'
					if (obj.length) == 0
						{}
					else
						h = {}
						c = 0
						objects.each {|val|
							h[c] = {}
							objects.each {|key|
								h[c][key] = val unless (key.class == Hash || key.class == Moo)
							}
							c += 1
						}
						h
					end
				else
					obj
			end
			y = src.ya2yaml(
				:syck_compatible => true
			)
#			puts y

			r = YAML.load(y)
			assert_equal(src,r)
		}
	end

	def test_roundtrip_various
		[
			[1,2,['c','d',[[['e']],[]],'f'],3,Time.new(),[[:foo]],nil,true,false,[],{},{[123,223]=>456},{[1]=>2,'a'=>'b','c' => [9,9,9],Time.new() => 'hoge'},],
			[],
			{[123,223]=>456},
			{},
			{'foo' => {1 => {2=>3,4=>5},6 => [7,8]}},
			"abc",
			" abc\n def\ndef\ndef\ndef\ndef\n",
			"abc\n def\ndef\n",
			"abc\n def\ndef\n\n",
			"abc\n def\ndef\n\n ",
			"abc\n def\ndef\n \n",
			"abc\n def\ndef \n \n",
			"abc\n def\ndef \n \n ",
			' ほげほげほげ',
			{"ほげ\nほげ\n ほげ" => 123},
			[["ほげ\nほげ\n ほげ"]],
			"ほげh\x4fge\nほげ\nほげ",
			[{'ほげ'=>'abc',"ほげ\nほげ"=>'ほげ'},'ほげ',@text],
			[Date.today,-9.011,0.023,4,-5,{1=>-2,-1=>@text,'_foo'=>'bar','ぬお-ぬお'=>321}],
			{1=>-2,-1=>@gif,'_foo'=>'bar','ぬお-ぬお'=>321},
		].each {|src|
			y = src.ya2yaml(
				:syck_compatible => true
			)
#			puts y

			r = YAML.load(y)
			assert_equal(src,r)
		}
	end

end

__END__
