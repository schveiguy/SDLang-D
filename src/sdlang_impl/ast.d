/// SDLang-D
/// Written in the D programming language.

module sdlang_impl.ast;

import std.array;
import std.conv;
import std.string;

import sdlang_impl.token;
import sdlang_impl.util;

enum ExtraInfo ///.
{
	None,      /// No Location info
	Locations, /// Include Location info
	All,       /// Include Location and original Token info
}
bool atLeast(ExtraInfo extraInfo, ExtraInfo minimum) ///.
{
	return cast(int)extraInfo >= cast(int)minimum;
}

///.
struct Attribute(ExtraInfo extraInfo = ExtraInfo.Locations)
{
	string namespace; ///.
	string name; ///.
	Value  value; ///.

	///.
	@property string fullName()
	{
		return namespace==""? name : text(namespace, ":", name);
	}

	static if(extraInfo.atLeast(ExtraInfo.Locations))
		Location location; ///.

	static if(extraInfo.atLeast(ExtraInfo.All))
		Token valueToken; ///.
}

class Tag(ExtraInfo extraInfo = ExtraInfo.Locations)
{
	static immutable defaultName = "content";

	Tag!extraInfo parent; ///.
	string  namespace; ///.
	string  name; /// Not including namespace
	Value[] values; ///.
	
	///.
	@property string fullName()
	{
		return namespace==""? name : text(namespace, ":", name);
	}

	Attribute!extraInfo[][string][string] attributes; /// attributes[namespace][name][0..$]
	Tag!extraInfo[][string][string]       tags;       /// tags[namespace][name][0..$]

	static if(extraInfo.atLeast(ExtraInfo.Locations))
		Location location; ///.

	static if(extraInfo.atLeast(ExtraInfo.All))
		Token[] valueTokens;  /// Same indicies as 'values' (unless you modify either this or 'values')
	
	///.
	this(Tag parent)
	{
		this.parent = parent;
	}

	///.
	this(Tag parent, string namespace, string name)
	{
		this.parent    = parent;
		this.namespace = namespace;
		this.name      = name;
	}
	
	/// Not the most efficient, but it works.
	string toDebugString()
	{
		Appender!string buf;
		
		buf.put("\n");
		buf.put("Tag ");
		if(namespace != "")
		{
			buf.put("[");
			buf.put(namespace);
			buf.put("]");
		}
		buf.put("'%s':\n".format(name));

		// Values
		foreach(val; values)
			buf.put("    (%s): %s\n".format(.toString(val.type), val));

		// Attributes
		foreach(attrsByNamespace; attributes)
		foreach(attrsByName; attrsByNamespace)
		foreach(attr; attrsByName)
		{
			string attrNamespace;
			if(attr.namespace != "")
				attrNamespace = "["~attr.namespace~"]";
			
			buf.put(
				"    %s%s(%s): %s\n".format(
					attrNamespace, attr.name, .toString(attr.value.type), attr.value
				)
			);
		}
		
		// Children
		foreach(tagsByNamespace; tags)
		foreach(tagsByName; tagsByNamespace)
		foreach(tag; tagsByName)
			buf.put( tag.toDebugString().replace("\n", "\n    ") );
		
		return buf.data;
	}
}
