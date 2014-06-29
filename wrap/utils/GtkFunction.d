/*
 * This file is part of gtkD.
 *
 * gtkD is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version, with
 * some exceptions, please read the COPYING file.
 *
 * gtkD is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with gtkD; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA
 */

module utils.GtkFunction;

import std.algorithm: among, startsWith;
import std.conv;
import std.range;
import std.string: splitLines, strip;

import utils.GtkStruct;
import utils.GtkType;
import utils.GtkWrapper;
import utils.XML;

enum GtkFunctionType : string
{
	Constructor = "constructor",
	Method = "method",
	Function = "function",
	Callback = "callback",
	Signal = "glib:signal"
}

final class GtkFunction
{
	string name;
	GtkFunctionType type;
	string doc;
	string cType;
	string libVersion;
	bool virtual = false;
	bool throws = false;
	bool lookupOverride; /// Force marking this function with overrride.
	bool noCode; /// Don't generate any class code for this function.

	GtkType returnType;
	GtkParam instanceParam;
	GtkParam[] params;

	GtkWrapper wrapper;
	GtkStruct strct;

	this (GtkWrapper wrapper, GtkStruct strct)
	{
		this.wrapper = wrapper;
		this.strct = strct;
	}

	void parse(T)(XMLReader!T reader)
	{
		name = reader.front.attributes["name"];
		type = cast(GtkFunctionType)reader.front.value;

		if ( "c:type" in reader.front.attributes )
		{
			cType = reader.front.attributes["c:type"];
			if ( type == GtkFunctionType.Callback )
				name = cType;
		}
		if ( "c:identifier" in reader.front.attributes )
			cType = reader.front.attributes["c:identifier"];
		if ( "version" in reader.front.attributes )
			libVersion = reader.front.attributes["version"];
		if ( "throws" in reader.front.attributes )
			throws = reader.front.attributes["throws"] == "1";

		reader.popFront();

		while( !reader.empty && !reader.endTag("constructor", "method", "function", "callback", "glib:signal") )
		{
			switch ( reader.front.value )
			{
				case "doc":
					reader.popFront();
					doc ~= reader.front.value;
					reader.popFront();
					break;
				case "doc-deprecated":
					reader.popFront();
					doc ~= "\n\nDeprecated: "~ reader.front.value;
					reader.popFront();
					break;
				case "return-value":
					returnType = new GtkType(wrapper);
					reader.popFront();

					while( !reader.empty && !reader.endTag("return-value") )
					{
						switch ( reader.front.value )
						{
							case "doc":
								reader.popFront();
								returnType.doc ~= reader.front.value;
								reader.popFront();
								break;
							case "array":
							case "type":
								returnType.parse(reader);
								break;
							default:
								assert(false, name ~": Unexpected tag: "~ reader.front.value);
						}
						reader.popFront();
					}
					break;
				case "parameters":
					reader.popFront();
					while( !reader.empty && !reader.endTag("parameters") )
					{
						switch ( reader.front.value )
						{
							case "instance-parameter":
								instanceParam = new GtkParam(wrapper);
								instanceParam.parse(reader);
								break;
							case "parameter":
								GtkParam param = new GtkParam(wrapper);
								param.parse(reader);
								params ~= param;
								break;
							default:
								assert(false, name ~": Unexpected tag: "~ reader.front.value);
						}
						reader.popFront();
					}
					break;
				default:
					assert(false, name ~": Unexpected tag: "~ reader.front.value);
			}
			reader.popFront();
		}
	}

	bool isVariadic()
	{
		if ( params.empty )
			return false;
		else if ( params[$-1].name == "..." )
			return true;

		return false;
	}

	string[] getCallbackDeclaration()
	{
		string[] buff;

		writeDocs(buff);

		string func = "extern(C) "~ tokenToGtkD(returnType.cType, wrapper.aliasses) ~" function(";

		foreach ( size_t i, param; params )
		{
			if ( i > 0 )
				func ~= ", ";

			func ~= tokenToGtkD(param.type.cType, wrapper.aliasses);

			if ( param.type.size > -1 )
				func ~= "["~ to!string(param.type.size) ~"]";

			func ~= " "~ tokenToGtkD(param.name, wrapper.aliasses);
		}

		func ~= ") "~ tokenToGtkD(name, wrapper.aliasses) ~";";

		buff ~= func;
		return buff;
	}

	string getExternal()
	{
		assert(type != GtkFunctionType.Callback);
		assert(type != GtkFunctionType.Signal);

		string ext;
		string type = stringToGtkD(returnType.cType, wrapper.aliasses);

		if ( type.startsWith("bool") )
			ext ~= type.replaceFirst("bool", "int");
		else
			ext ~= type;

		ext ~= " function(";

		if ( instanceParam )
		{
			ext ~= stringToGtkD(instanceParam.type.cType, wrapper.aliasses);
			ext ~= " ";
			ext ~= tokenToGtkD(instanceParam.name, wrapper.aliasses);
		}

		foreach ( i, param; params )
		{
			if ( i > 0 || instanceParam )
				ext ~= ", ";

			type = stringToGtkD(param.type.cType, wrapper.aliasses);

			if ( type.startsWith("bool") )
				ext ~= type.replaceFirst("bool", "int");
			else
				ext ~= type;

			ext ~= " ";
			if ( param.name != "..." )
				ext ~= tokenToGtkD(param.name, wrapper.aliasses);
		}

		if ( throws )
			ext ~= ", GError** err";

		ext ~= ") c_"~ cType ~";";

		return ext;
	}

	string[] getDeclaration()
	{
		string[] buff;
		string dec = "public ";

		resolveLength();
		writeDocs(buff);

		if ( type == GtkFunctionType.Constructor )
		{
			dec ~= "this(";
		}
		else
		{
			if ( type == GtkFunctionType.Function )
				dec ~= "static ";

			if ( strct.parentStruct && name in strct.parentStruct.functions )
				dec ~= "override ";

			dec ~= getType(returnType) ~" ";
			dec ~= tokenToGtkD(name, wrapper.aliasses) ~"(";
		}

		size_t i;
		foreach( param; params )
		{
			if ( param.lengthFor )
				continue;

			if ( returnType.length > -1 && param == params[returnType.length] )
				continue;

			if ( i++ > 0 )
				dec ~= ", ";

			if ( param.direction == GtkParamDirection.Out )
				dec ~= "out ";
			else if ( param.direction == GtkParamDirection.InOut )
				dec ~= "ref ";

			dec ~= getType(param.type, param.direction) ~" ";
			dec ~= tokenToGtkD(param.name, wrapper.aliasses);
		}

		dec ~= ")";
		buff ~= dec;

		return buff;
	}

	string[] getBody()
	{
		string[] buff;
		string[] outToD;
		string gtkCall = cType ~"(";

		GtkStruct returnDType;

		if ( returnType.isArray() )
			returnDType = strct.pack.getStruct(returnType.elementType.name);
		else
			returnDType = strct.pack.getStruct(returnType.name);

		if ( instanceParam )
		{
			GtkStruct dType = strct.pack.getStruct(instanceParam.type.name);

			if ( dType.type == GtkStructType.Interface )
				gtkCall ~= dType.getHandleFunc() ~"()";
			else
				gtkCall ~= dType.getHandleVar();
		}

		foreach( i, param; params )
		{
			GtkStruct dType;
			string id = tokenToGtkD(param.name, wrapper.aliasses);

			if ( param.type.isArray() )
				dType = strct.pack.getStruct(param.type.elementType.name);
			else
				dType = strct.pack.getStruct(param.type.name);

			if ( instanceParam || i > 0 )
				gtkCall ~= ", ";

			if ( isStringType(param.type) )
			{
				if ( param.type.elementType )
				{
					// out string[], ref string[]
					if ( param.direction != GtkParamDirection.Default )
					{
						buff ~= "char** out"~ id ~" = ";

						if ( param.direction == GtkParamDirection.Out )
							buff[$-1] ~= "null;";
						else
							buff[$-1] ~= "Str.toStringzArray("~ id ~");";

						string len = lenId(param.type);
						if ( !len.empty )
							len = ", "~ len;

						gtkCall ~= "&out"~ id;
						outToD ~= id ~" = Str.toStringArray(out"~ id ~ len ~");";
					}
					// string, string[]
					else
					{
						if ( param.type.elementType.cType == "char" )
							gtkCall ~= "Str.toStringz("~ id ~")";
						else
							gtkCall ~= "Str.toStringzArray("~ id ~")";
					}
				}
				else
				{
					// out string, ref string
					if ( param.direction != GtkParamDirection.Default )
					{
						buff ~= "char* out"~ id ~" = ";

						if ( param.direction == GtkParamDirection.Out )
							buff[$-1] ~= "null;";
						else
							buff[$-1] ~= "Str.toStringz("~ id ~");";

						string len = lenId(param.type);
						if ( !len.empty )
							len = ", "~ len;

						gtkCall ~= "&out"~ id;
						outToD ~= id ~" = Str.toString(out"~ id ~ len ~");";
					}
					// string
					else
					{
						gtkCall ~= "Str.toStringz("~ id ~")";
					}
				}
			}
			else if ( dType && dType.type != GtkStructType.Record )
			{
				if ( param.type.isArray() )
				{
					GtkType elementType = param.type.elementType;
					GtkStruct dElementType = strct.pack.getStruct(elementType.name);

					// out gtkdType[], ref gtkdType[]
					if ( param.direction != GtkParamDirection.Default )
					{
						if ( param.direction == GtkParamDirection.Out )
						{
							buff ~= elementType.cType.chomp("*") ~"** out"~ id ~" = null;";
						}
						else
						{
							buff ~= "";
							buff ~= elementType.cType.chomp("*") ~ "*[] inout"~ id ~" = new "~ elementType.cType.chomp("*") ~"*["~ id ~".length];";
							buff ~= "for ( int i = 0; i < "~ id ~".length ; i++ )";
							buff ~= "{";
							buff ~= "inout"~ id ~"[i] = "~ id~ "[i]."~ dElementType.getHandleFunc() ~"();";
							buff ~= "}";
							buff ~= "";
							buff ~= elementType.cType.chomp("*") ~ "** out"~ id ~" = inout"~ id ~".ptr;";
						}

						gtkCall ~= "out"~ id ~".ptr";

						outToD ~= "";
						outToD ~= id ~" = new "~ dElementType.name ~"["~ lenId(param.type) ~"];";
						outToD ~= "for(int i = 0; i < "~ lenId(param.type) ~"; i++)";
						outToD ~= "{";
						outToD ~= id ~"[i] = " ~ construct(dType) ~ "(cast(" ~ param.type.elementType.cType ~ ") out"~ id ~"[i]);";
						outToD ~= "}";
					}
					// gtkdType[]
					else
					{
						buff ~= "";
						buff ~= elementType.cType ~ "[] "~ id ~"Array = new "~ elementType.cType ~"["~ id ~".length];";
						buff ~= "for ( int i = 0; i < "~ id ~".length ; i++ )";
						buff ~= "{";
						buff ~= id ~"Array[i] = "~ id ~"[i]."~ dElementType.getHandleFunc() ~"();";
						buff ~= "}";
						buff ~= "";

						gtkCall ~= id ~"Array.ptr";
					}
				}
				else
				{
					// out gtkdType, ref gtkdType
					if ( param.direction != GtkParamDirection.Default )
					{
						buff ~= param.type.cType.chomp("*") ~"* out"~ id ~" = ";

						if ( param.direction == GtkParamDirection.Out )
							buff[$-1] ~= "null;";
						else
							buff[$-1] ~= id ~"."~ dType.getHandleFunc() ~"();";

						gtkCall ~= "&out"~ id;

						outToD ~= id ~" = "~ construct(dType) ~"(out"~ id ~");";
					}
					// gtkdType
					else
					{
						gtkCall ~= "("~ id ~" is null) ? null : "~ id ~"."~ dType.getHandleFunc ~"()";
					}
				}
			}
			else if ( param.lengthFor || returnType.length == i )
			{
				string arrId;

				if ( param.lengthFor )
					arrId = tokenToGtkD(param.lengthFor.name, wrapper.aliasses);

				final switch ( param.direction ) with (GtkParamDirection)
				{
					case Default:
						gtkCall ~= "cast(int)"~ arrId ~".length";
						break;
					case Out:
						buff ~= "int "~ id ~";";
						gtkCall ~= "&"~id;
						break;
					case InOut:
						buff ~= "int "~ id ~" = cast(int)"~ arrId ~".length;";
						gtkCall ~= "&"~id;
						break;
				}
			}
			else
			{
				if ( param.type.isArray() )
				{
					// out T[], ref T[]
					if ( param.direction != GtkParamDirection.Default )
					{
						buff ~= param.type.cType.chomp("*") ~"* out"~ id ~" = ";

						if ( param.direction == GtkParamDirection.Out )
							buff[$-1] ~= "null;";
						else
							buff[$-1] ~= id ~".ptr";

						gtkCall ~= "&out"~ id ~"";

						outToD ~= id ~" = out"~ id ~"[0 .. "~ lenId(param.type) ~"];";
					}
					// T[]
					else
					{
						gtkCall ~= id ~".ptr";
					}
				}
				else
				{
					// out T, ref T
					if ( param.direction != GtkParamDirection.Default )
					{
						gtkCall ~= "&"~ id;
					}
					// T
					else
					{
						gtkCall ~= id;
					}
				}
			}
		}

		if ( throws )
		{
			buff ~= "GError* err = null;";
			gtkCall ~= ", &err";

			string[] check;
			check ~= "";
			check ~= "if (err !is null)";
			check ~= "{";
			check ~= "throw new GException( new ErrorG(err) );";
			check ~= "}";

			outToD = check ~ outToD;
		}

		gtkCall ~= ")";

		if ( !buff.empty )
			buff ~= "";

		if ( returnType.name == "none" )
		{
			buff ~= gtkCall ~";";

			if ( !outToD.empty )
			{
				buff ~= "";
				buff ~= outToD;
			}

			return buff;
		}
		else if ( type == GtkFunctionType.Constructor )
		{
			buff ~= "auto p = " ~ gtkCall ~";";

			buff ~= "";
			buff ~= "if(p is null)";
			buff ~= "{";
			buff ~= "throw new ConstructionException(\"null returned by " ~ name ~ "\");";
			buff ~= "}";
			buff ~= "";

			if ( !outToD.empty )
			{
				buff ~= outToD;
				buff ~= "";
			}

			/*
			 * Casting is needed because some GTK+ functions
			 * can return void pointers or base types.
			 */
			buff ~= "this(cast(" ~ strct.cType ~ ") p);";
			
			return buff;
		}
		else if ( isStringType(returnType) )
		{
			if ( outToD.empty )
			{
				if ( returnType.elementType && returnType.elementType.cType != "char" )
					buff ~= "return Str.toStringArray(" ~ gtkCall ~");";
				else
					buff ~= "return Str.toString(" ~ gtkCall ~");";

				return buff;
			}

			buff ~= "auto p = "~ gtkCall ~";";
			buff ~= "";

			if ( !outToD.empty )
			{
				buff ~= "";
				buff ~= outToD;
			}

			string len = lenId(returnType);
			if ( !len.empty )
				len = ", "~ len;

			if ( returnType.elementType && returnType.elementType.cType != "char" )
				buff ~= "return Str.toStringArray(p"~ len ~");";
			else
				buff ~= "return Str.toString(p"~ len ~");";

			return buff;
		}
		else if ( returnDType && returnDType.type != GtkStructType.Record )
		{
			buff ~= "auto p = "~ gtkCall ~";";

			if ( !outToD.empty )
			{
				buff ~= "";
				buff ~= outToD;
			}

			buff ~= "";
			buff ~= "if(p is null)";
			buff ~= "{";
			buff ~= "return null;";
			buff ~= "}";
			buff ~= "";

			if ( returnType.isArray() )
			{
				buff ~= returnDType.name ~"[] arr = new "~ returnDType.name ~"["~ lenId(returnType) ~"];";
				buff ~= "for(int i = 0; i < "~ lenId(returnType) ~"; i++)";
				buff ~= "{";
				buff ~= "\tarr[i] = "~ construct(returnDType) ~"(cast("~ returnType.elementType.cType ~") p[i]);";
				buff ~= "}";
				buff ~= "";
				buff ~= "return arr;";
			}
			else
			{
				buff ~= "return "~ construct(returnDType) ~"(cast("~ returnDType.cType ~") p);";
			}

			return buff;
		}
		else
		{
			if ( returnType.name == "gboolean" )
				gtkCall ~= " != 0";

			if ( returnType.elementType is null && outToD.empty )
			{
				buff ~= "return "~ gtkCall ~";";
				return buff;
			}

			buff ~= "auto p = "~ gtkCall ~";";
			buff ~= "";

			if ( !outToD.empty )
			{
				buff ~= "";
				buff ~= outToD;
			}

			if ( returnType.elementType )
				buff ~= "return p[0 .. "~ lenId(returnType) ~"];";
			else
				buff ~= "return p;";

			return buff;
		}

		assert(false, "Unexpected function: "~ name);
	}

	string getSignalName()
	{
		assert(type == GtkFunctionType.Signal);

		char pc;
		string signalName;

		foreach ( size_t count, char c; name )
		{
			if ( count == 0 )
			{
				signalName ~= std.ascii.toUpper(c);
			}
			else
			{
				if ( c!='-' && c!='_' )
				{
					if ( pc=='-' || pc=='_' )
						signalName ~= toUpper(c);
					else
						signalName ~= c;
				}
			}
			pc = c;
		}

		if ( !signalName.among("MapEvent", "UnmapEvent", "DestroyEvent") &&
		    endsWith(signalName, "Event") )
		{
			signalName = signalName[0..signalName.length-5];
		}

		return signalName;
	}

	string getDelegateDecleration()
	{
		assert(type == GtkFunctionType.Signal);

		string buff = getType(returnType) ~ " delegate(";

		foreach ( param; params )
		{
			buff ~= getType(param.type) ~ ", ";
		}

		if ( strct.type == GtkStructType.Interface )
			buff ~= strct.name ~"IF)";
		else
			buff ~= strct.name ~")";

		return buff;
	}

	string[] getAddListenerdeclaration()
	{
		string[] buff;

		writeDocs(buff);
		buff ~= "void addOn"~ getSignalName() ~"("~ getDelegateDecleration() ~" dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)";

		return buff;
	}

	string[] getAddListenerBody()
	{
		string[] buff;

		buff ~= "{";
		buff ~= "if ( \""~ getSignalName() ~"\" !in connectedSignals )";
		buff ~= "{";

		if ( strct.name != "StatusIcon")
		{
			switch ( name )
			{
				case  "button-press-event":      buff ~= "addEvents(EventMask.BUTTON_PRESS_MASK);";      break;
				case  "button-release-event":    buff ~= "addEvents(EventMask.BUTTON_RELEASE_MASK);";    break;
				case  "enter-notify-event":      buff ~= "addEvents(EventMask.ENTER_NOTIFY_MASK);";      break;
				case  "focus-in-event":          buff ~= "addEvents(EventMask.FOCUS_CHANGE_MASK);";      break;
				case  "focus-out-event":         buff ~= "addEvents(EventMask.FOCUS_CHANGE_MASK);";      break;
				case  "key-press-event":         buff ~= "addEvents(EventMask.KEY_PRESS_MASK);";         break;
				case  "key-release-event":       buff ~= "addEvents(EventMask.KEY_RELEASE_MASK);";       break;
				case  "leave-notify-event":      buff ~= "addEvents(EventMask.LEAVE_NOTIFY_MASK);";      break;
				case  "motion-notify-event":     buff ~= "addEvents(EventMask.POINTER_MOTION_MASK);";    break;
				case  "property-notify-event":   buff ~= "addEvents(EventMask.PROPERTY_CHANGE_MASK);";   break;
				case  "proximity-in-event":      buff ~= "addEvents(EventMask.PROXIMITY_IN_MASK);";      break;
				case  "proximity-out-event":     buff ~= "addEvents(EventMask.PROXIMITY_OUT_MASK);";     break;
				case  "scroll-event":            buff ~= "addEvents(EventMask.SCROLL_MASK);";            break;
				case  "visibility-notify-event": buff ~= "addEvents(EventMask.VISIBILITY_NOTIFY_MASK);"; break;

				default: break;
			}
		}

		buff ~= "Signals.connectData(";
		buff ~= "getStruct(),";
		buff ~= "\""~ name ~"\",";
		buff ~= "cast(GCallback)&callBack"~ getSignalName() ~",";

		if ( strct.type == GtkStructType.Interface )
			buff ~= "cast(void*)cast("~ strct.name ~"IF)this,";
		else
			buff ~= "cast(void*)this,";

		buff ~= "null,";
		buff ~= "connectFlags);";
		buff ~= "connectedSignals[\""~ name ~"\"] = 1;";
		buff ~= "}";

		if ( strct.type == GtkStructType.Interface )
			buff ~= "_on"~ getSignalName() ~"Listeners ~= dlg;";
		else
			buff ~= "on"~ getSignalName() ~"Listeners ~= dlg;";

		buff ~= "}";

		return buff;
	}

	string[] getSignalCallback()
	{
		string[] buff;

		buff ~= "extern(C) static "
			~ tokenToGtkD(returnType.cType, wrapper.aliasses)
			~" callBack"~ getSignalName() ~"("~ getCallbackParams() ~")";

		buff ~= "{";
		buff ~= "foreach ( "~ getDelegateDecleration() ~" dlg; _"~ strct.name.toLower() ~".on"~ getSignalName() ~"Listeners )";
		buff ~= "{";

		if ( strct.type == GtkStructType.Interface )
		{
			buff ~= "if ( dlg("~ getCallbackVars() ~") )";
			buff ~= "{";
			buff ~= "return 1;";
			buff ~= "}";
			buff ~= "}";
			buff ~= "";
			buff ~= "return 0;";
		}
		else
		{
			buff ~= "dlg("~ getCallbackVars() ~");";
			buff ~= "}";
		}

		buff ~= "}";

		return buff;
	}

	void writeDocs(ref string[] buff)
	{
		if ( (doc || returnType.doc) && wrapper.includeComments )
		{
			buff ~= "/**";
			foreach ( line; doc.splitLines() )
				buff ~= " * "~ line.strip();

			if ( !params.empty )
			{
				buff ~= " *";
				buff ~= " * Params:";

				foreach ( param; params )
				{
					if ( param.doc.empty )
						continue;

					string[] lines = param.doc.splitLines();
					buff ~= " *     "~ tokenToGtkD(param.name, wrapper.aliasses) ~" = "~ lines[0];
					foreach( line; lines[1..$] )
						buff ~= " *         "~ line.strip();
				}
			}

			if ( returnType.doc )
			{
				string[] lines = returnType.doc.splitLines();
				if ( doc )
					buff ~= " *";
				buff ~= " * Return: "~ lines[0];

				foreach( line; lines[1..$] )
					buff ~= " *     "~ line.strip();
			}

			if ( libVersion )
			{
				buff ~= " *";
				buff ~= " * Since: "~ libVersion;
			}

			if ( throws || type == GtkFunctionType.Constructor )
				buff ~= " *";

			if ( throws )
				buff ~= " * Throws: GException on failure.";

			if ( type == GtkFunctionType.Constructor )
				buff ~= " * Throws: ConstructionException GTK+ fails to create the object.";

			buff ~= " */";
		}
	}

	private void resolveLength()
	{
		foreach( param; params )
		{
			if ( param.type.length > -1 )
				params[param.type.length].lengthFor = param;
		}
	}

	/**
	 * Gen an string representation of the type.
	 */
	private string getType(GtkType type, GtkParamDirection direction = GtkParamDirection.Default)
	{
		if ( type.elementType )
		{
			string size;

			if ( !type.isArray() )
				goto NoArray;

			if ( type.size > -1 )
				size = to!string(type.size);

			string elmType = getType(type.elementType, direction);

			if ( elmType == "char" || elmType == "const(char)" )
				return "string";

			return elmType ~"["~ size ~"]";
		}
		else if ( !type.elementType && type.zeroTerminated )
		{
			return getType(type, GtkParamDirection.Out) ~"[]";
		}
		else NoArray:
		{
			if ( type is null || type.name == "none" )
				return "void";
			else if ( type.name in strct.structWrap )
				return strct.structWrap[type.name];
			else if ( type.cType == "gchar*" || type.cType == "const(char)*" )
				return "string";
			else if ( type.name == type.cType )
				return stringToGtkD(type.name, wrapper.aliasses);

			GtkStruct dType = strct.pack.getStruct(type.name);

			if ( dType && dType.type != GtkStructType.Record )
				return dType.name;
			else if ( type.cType.empty && dType && dType.type == GtkStructType.Record )
				return dType.cType ~ "*";
		}

		if ( type.cType.empty )
			return stringToGtkD(type.name, wrapper.aliasses);

		if ( direction != GtkParamDirection.Default )
			return stringToGtkD(type.cType[0..$-1], wrapper.aliasses);

		return stringToGtkD(type.cType, wrapper.aliasses);
	}

	private bool isStringType(GtkType type)
	{
		if ( type.cType.startsWith("gchar*", "char*", "const(char)*") )
			return true;
		else if ( type.name.among("utf8", "filename") )
			return true;
		else if ( type.elementType && type.elementType.cType.startsWith("gchar", "char", "const(char)") )
			return true;
		else
			return false;
	}

	private string lenId(GtkType type)
	{
		if ( type.length > -1 )
			return tokenToGtkD(params[type.length].name, wrapper.aliasses);
		//The c function returns the length.
		else if ( type.length == -2 )
			return "p";
		else if ( type.size > -1 )
			return to!string(type.size);

		//TODO: zero-terminated?

		return null;
	}

	private string construct(GtkStruct type)
	{
		if ( type.pack.name.among("cairo", "glib", "gthread") )
			return "new "~ type.name;
		else if( type.type == GtkStructType.Interface )
			return "ObjectG.getDObject!("~ type.name ~", "~ type.name ~"IF)";
		else
			return "ObjectG.getDObject!("~ type.name ~")";
	}

	private string getCallbackParams()
	{
		string buff;

		buff = strct.cType ~" "~ strct.name.toLower() ~"Struct";
		foreach( param; params )
		{
			GtkStruct par = strct.pack.getStruct(param.type.name);

			if ( par && par.type == GtkStructType.Record )
				buff ~= ", "~ par.cType ~"* "~ tokenToGtkD(param.name, wrapper.aliasses);
			else if ( par )
				buff ~= ", "~ par.cType ~" "~ tokenToGtkD(param.name, wrapper.aliasses);
			else
				buff ~= ", "~ param.type.cType ~" "~ tokenToGtkD(param.name, wrapper.aliasses);
		}

		if ( strct.type == GtkStructType.Interface )
			buff ~= ", "~ strct.name ~"IF _"~ strct.name.toLower();
		else
			buff ~= ", "~ strct.name ~" _"~ strct.name.toLower();

		return buff;
	}

	private string getCallbackVars()
	{
		string buff;

		foreach( i, param; params )
		{
			if ( i < 0 )
				buff ~= ", ";

			GtkStruct par = strct.pack.getStruct(param.type.name);

			if ( par && par.type != GtkStructType.Record )
				buff ~= construct(par);
			else
				buff ~= tokenToGtkD(param.name, wrapper.aliasses);
		}

		if ( !buff.empty )
			buff ~= ", ";
		buff ~= strct.name.toLower() ~"Struct";

		return buff;
	}
}

enum GtkParamDirection : string
{
	Default = "",
	Out = "out",
	InOut = "inout",
}

final class GtkParam
{
	string doc;
	string name;
	GtkType type;
	GtkParamDirection direction;

	GtkParam lengthFor;
	GtkWrapper wrapper;

	this(GtkWrapper wrapper)
	{
		this.wrapper = wrapper;
	}

	void parse(T)(XMLReader!T reader)
	{
		name = reader.front.attributes["name"];

		if ( "direction" in reader.front.attributes )
			direction = cast(GtkParamDirection)reader.front.attributes["direction"];

		reader.popFront();

		while( !reader.empty && !reader.endTag("parameter", "instance-parameter") )
		{
			if ( reader.front.type == XMLNodeType.EndTag )
			{
				reader.popFront();
				continue;
			}

			switch(reader.front.value)
			{
				case "doc":
					reader.popFront();
					doc ~= reader.front.value;
					reader.popFront();
					break;
				case "doc-deprecated":
					reader.popFront();
					doc ~= "\n\nDeprecated: "~ reader.front.value;
					reader.popFront();
					break;
				case "array":
				case "type":
					type = new GtkType(wrapper);
					type.parse(reader);
					break;
				case "varargs":
					type = new GtkType(wrapper);
					type.name = "...";
					type.cType = "...";
					break;
				default:
					assert(false, name ~": Unexpected tag: "~ reader.front.value);
			}

			reader.popFront();
		}
	}
}