/*
 * This file is part of gtkD.
 *
 * gtkD is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * gtkD is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with gtkD; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
 
// generated automatically - do not change
// find conversion definition on APILookup.txt
// implement new conversion functionalities on the wrap.utils pakage

/*
 * Conversion parameters:
 * inFile  = gtk-High-level-Printing-API.html
 * outPack = gtk
 * outFile = PrintOperation
 * strct   = GtkPrintOperation
 * realStrct=
 * ctorStrct=
 * clss    = PrintOperation
 * interf  = 
 * class Code: Yes
 * interface Code: No
 * template for:
 * extend  = 
 * implements:
 * 	- PrintOperationPreviewIF
 * prefixes:
 * 	- gtk_print_operation_
 * omit structs:
 * omit prefixes:
 * 	- gtk_print_operation_preview_
 * omit code:
 * omit signals:
 * 	- got-page-size
 * 	- ready
 * imports:
 * 	- glib.Str
 * 	- gtk.Window
 * 	- gtk.PageSetup
 * 	- gtk.PrintContext
 * 	- gtk.PrintSettings
 * 	- gtk.PrintOperationPreviewT
 * 	- gtk.PrintOperationPreviewIF
 * 	- glib.ErrorG
 * 	- glib.GException
 * structWrap:
 * 	- GtkPageSetup* -> PageSetup
 * 	- GtkPrintContext* -> PrintContext
 * 	- GtkPrintSettings* -> PrintSettings
 * 	- GtkWindow* -> Window
 * module aliases:
 * local aliases:
 * overrides:
 */

module gtk.PrintOperation;

public  import gtkc.gtktypes;

private import gtkc.gtk;
private import glib.ConstructionException;

private import gobject.Signals;
public  import gtkc.gdktypes;

private import glib.Str;
private import gtk.Window;
private import gtk.PageSetup;
private import gtk.PrintContext;
private import gtk.PrintSettings;
private import gtk.PrintOperationPreviewT;
private import gtk.PrintOperationPreviewIF;
private import glib.ErrorG;
private import glib.GException;



private import gobject.ObjectG;

/**
 * Description
 * GtkPrintOperation is the high-level, portable printing API. It looks
 * a bit different than other GTK+ dialogs such as the GtkFileChooser,
 * since some platforms don't expose enough infrastructure to implement
 * a good print dialog. On such platforms, GtkPrintOperation uses the
 * native print dialog. On platforms which do not provide a native
 * print dialog, GTK+ uses its own, see GtkPrintUnixDialog.
 * The typical way to use the high-level printing API is to create a
 * GtkPrintOperation object with gtk_print_operation_new() when the user
 * selects to print. Then you set some properties on it, e.g. the page size,
 * any GtkPrintSettings from previous print operations, the number of pages,
 * the current page, etc.
 * Then you start the print operation by calling gtk_print_operation_run().
 * It will then show a dialog, let the user select a printer and options.
 * When the user finished the dialog various signals will be emitted on the
 * GtkPrintOperation, the main one being ::draw-page, which you are supposed
 * to catch and render the page on the provided GtkPrintContext using Cairo.
 * Example 41. The high-level printing API
 * static GtkPrintSettings *settings = NULL;
 * static void
 * do_print (void)
 * {
	 *  GtkPrintOperation *print;
	 *  GtkPrintOperationResult res;
	 *  print = gtk_print_operation_new ();
	 *  if (settings != NULL)
	 *  gtk_print_operation_set_print_settings (print, settings);
	 *  g_signal_connect (print, "begin_print", G_CALLBACK (begin_print), NULL);
	 *  g_signal_connect (print, "draw_page", G_CALLBACK (draw_page), NULL);
	 *  res = gtk_print_operation_run (print, GTK_PRINT_OPERATION_ACTION_PRINT_DIALOG,
	 *  GTK_WINDOW (main_window), NULL);
	 *  if (res == GTK_PRINT_OPERATION_RESULT_APPLY)
	 *  {
		 *  if (settings != NULL)
		 *  g_object_unref (settings);
		 *  settings = g_object_ref (gtk_print_operation_get_print_settings (print));
	 *  }
	 *  g_object_unref (print);
 * }
 * By default GtkPrintOperation uses an external application to do
 * print preview. To implement a custom print preview, an application
 * must connect to the preview signal. The functions
 * gtk_print_operation_print_preview_render_page(),
 * gtk_print_operation_preview_end_preview() and
 * gtk_print_operation_preview_is_selected() are useful
 * when implementing a print preview.
 * Printing support was added in GTK+ 2.10.
 */
public class PrintOperation : ObjectG, PrintOperationPreviewIF
{
	
	/** the main Gtk struct */
	protected GtkPrintOperation* gtkPrintOperation;
	
	
	public GtkPrintOperation* getPrintOperationStruct()
	{
		return gtkPrintOperation;
	}
	
	
	/** the main Gtk struct as a void* */
	protected override void* getStruct()
	{
		return cast(void*)gtkPrintOperation;
	}
	
	/**
	 * Sets our main struct and passes it to the parent class
	 */
	public this (GtkPrintOperation* gtkPrintOperation)
	{
		if(gtkPrintOperation is null)
		{
			this = null;
			return;
		}
		//Check if there already is a D object for this gtk struct
		void* ptr = getDObject(cast(GObject*)gtkPrintOperation);
		if( ptr !is null )
		{
			this = cast(PrintOperation)ptr;
			return;
		}
		super(cast(GObject*)gtkPrintOperation);
		this.gtkPrintOperation = gtkPrintOperation;
	}
	
	// add the PrintOperationPreview capabilities
	mixin PrintOperationPreviewT!(GtkPrintOperation);
	
	/**
	 */
	int[char[]] connectedSignals;
	
	void delegate(PrintContext, PrintOperation)[] onBeginPrintListeners;
	/**
	 * Emitted after the user has finished changing print settings
	 * in the dialog, before the actual rendering starts.
	 * A typical use for ::begin-print is to use the parameters from the
	 * GtkPrintContext and paginate the document accordingly, and then
	 * set the number of pages with gtk_print_operation_set_n_pages().
	 * Since 2.10
	 */
	void addOnBeginPrint(void delegate(PrintContext, PrintOperation) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)
	{
		if ( !("begin-print" in connectedSignals) )
		{
			Signals.connectData(
			getStruct(),
			"begin-print",
			cast(GCallback)&callBackBeginPrint,
			cast(void*)this,
			null,
			connectFlags);
			connectedSignals["begin-print"] = 1;
		}
		onBeginPrintListeners ~= dlg;
	}
	extern(C) static void callBackBeginPrint(GtkPrintOperation* operationStruct, GtkPrintContext* context, PrintOperation printOperation)
	{
		foreach ( void delegate(PrintContext, PrintOperation) dlg ; printOperation.onBeginPrintListeners )
		{
			dlg(new PrintContext(context), printOperation);
		}
	}
	
	GObject* delegate(PrintOperation)[] onCreateCustomWidgetListeners;
	/**
	 * Emitted when displaying the print dialog. If you return a
	 * widget in a handler for this signal it will be added to a custom
	 * tab in the print dialog. You typically return a container widget
	 * with multiple widgets in it.
	 * The print dialog owns the returned widget, and its lifetime is not
	 * controlled by the application. However, the widget is guaranteed
	 * to stay around until the "custom-widget-apply"
	 * signal is emitted on the operation. Then you can read out any
	 * information you need from the widgets.
	 * Since 2.10
	 */
	void addOnCreateCustomWidget(GObject* delegate(PrintOperation) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)
	{
		if ( !("create-custom-widget" in connectedSignals) )
		{
			Signals.connectData(
			getStruct(),
			"create-custom-widget",
			cast(GCallback)&callBackCreateCustomWidget,
			cast(void*)this,
			null,
			connectFlags);
			connectedSignals["create-custom-widget"] = 1;
		}
		onCreateCustomWidgetListeners ~= dlg;
	}
	extern(C) static void callBackCreateCustomWidget(GtkPrintOperation* operationStruct, PrintOperation printOperation)
	{
		foreach ( GObject* delegate(PrintOperation) dlg ; printOperation.onCreateCustomWidgetListeners )
		{
			dlg(printOperation);
		}
	}
	
	void delegate(GtkWidget*, PrintOperation)[] onCustomWidgetApplyListeners;
	/**
	 * Emitted right before "begin-print" if you added
	 * a custom widget in the "";create-custom-widget handler.
	 * When you get this signal you should read the information from the
	 * custom widgets, as the widgets are not guaraneed to be around at a
	 * later time.
	 * Since 2.10
	 */
	void addOnCustomWidgetApply(void delegate(GtkWidget*, PrintOperation) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)
	{
		if ( !("custom-widget-apply" in connectedSignals) )
		{
			Signals.connectData(
			getStruct(),
			"custom-widget-apply",
			cast(GCallback)&callBackCustomWidgetApply,
			cast(void*)this,
			null,
			connectFlags);
			connectedSignals["custom-widget-apply"] = 1;
		}
		onCustomWidgetApplyListeners ~= dlg;
	}
	extern(C) static void callBackCustomWidgetApply(GtkPrintOperation* operationStruct, GtkWidget* widget, PrintOperation printOperation)
	{
		foreach ( void delegate(GtkWidget*, PrintOperation) dlg ; printOperation.onCustomWidgetApplyListeners )
		{
			dlg(widget, printOperation);
		}
	}
	
	void delegate(GtkPrintOperationResult, PrintOperation)[] onDoneListeners;
	/**
	 * Emitted when the print operation run has finished doing
	 * everything required for printing.
	 * result gives you information about what happened during the run.
	 * If result is GTK_PRINT_OPERATION_RESULT_ERROR then you can call
	 * gtk_print_operation_get_error() for more information.
	 * If you enabled print status tracking then
	 * gtk_print_operation_is_finished() may still return FALSE
	 * after "done" was emitted.
	 * Since 2.10
	 */
	void addOnDone(void delegate(GtkPrintOperationResult, PrintOperation) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)
	{
		if ( !("done" in connectedSignals) )
		{
			Signals.connectData(
			getStruct(),
			"done",
			cast(GCallback)&callBackDone,
			cast(void*)this,
			null,
			connectFlags);
			connectedSignals["done"] = 1;
		}
		onDoneListeners ~= dlg;
	}
	extern(C) static void callBackDone(GtkPrintOperation* operationStruct, GtkPrintOperationResult result, PrintOperation printOperation)
	{
		foreach ( void delegate(GtkPrintOperationResult, PrintOperation) dlg ; printOperation.onDoneListeners )
		{
			dlg(result, printOperation);
		}
	}
	
	void delegate(PrintContext, gint, PrintOperation)[] onDrawPageListeners;
	/**
	 * Emitted for every page that is printed. The signal handler
	 * must render the page_nr's page onto the cairo context obtained
	 * from context using gtk_print_context_get_cairo_context().
	 * static void
	 * draw_page (GtkPrintOperation *operation,
	 *  GtkPrintContext *context,
	 *  gint page_nr,
	 *  gpointer user_data)
	 * {
		 *  cairo_t *cr;
		 *  PangoLayout *layout;
		 *  gdouble width, text_height;
		 *  gint layout_height;
		 *  PangoFontDescription *desc;
		 *
		 *  cr = gtk_print_context_get_cairo_context (context);
		 *  width = gtk_print_context_get_width (context);
		 *
		 *  cairo_rectangle (cr, 0, 0, width, HEADER_HEIGHT);
		 *
		 *  cairo_set_source_rgb (cr, 0.8, 0.8, 0.8);
		 *  cairo_fill (cr);
		 *
		 *  layout = gtk_print_context_create_pango_layout (context);
		 *
		 *  desc = pango_font_description_from_string ("sans 14");
		 *  pango_layout_set_font_description (layout, desc);
		 *  pango_font_description_free (desc);
		 *
		 *  pango_layout_set_text (layout, "some text", -1);
		 *  pango_layout_set_width (layout, width * PANGO_SCALE);
		 *  pango_layout_set_alignment (layout, PANGO_ALIGN_CENTER);
		 *
		 *  pango_layout_get_size (layout, NULL, layout_height);
		 *  text_height = (gdouble)layout_height / PANGO_SCALE;
		 *
		 *  cairo_move_to (cr, width / 2, (HEADER_HEIGHT - text_height) / 2);
		 *  pango_cairo_show_layout (cr, layout);
		 *
		 *  g_object_unref (layout);
	 * }
	 * Use gtk_print_operation_set_use_full_page() and
	 * gtk_print_operation_set_unit() before starting the print operation
	 * to set up the transformation of the cairo context according to your
	 * needs.
	 * Since 2.10
	 */
	void addOnDrawPage(void delegate(PrintContext, gint, PrintOperation) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)
	{
		if ( !("draw-page" in connectedSignals) )
		{
			Signals.connectData(
			getStruct(),
			"draw-page",
			cast(GCallback)&callBackDrawPage,
			cast(void*)this,
			null,
			connectFlags);
			connectedSignals["draw-page"] = 1;
		}
		onDrawPageListeners ~= dlg;
	}
	extern(C) static void callBackDrawPage(GtkPrintOperation* operationStruct, GtkPrintContext* context, gint pageNr, PrintOperation printOperation)
	{
		foreach ( void delegate(PrintContext, gint, PrintOperation) dlg ; printOperation.onDrawPageListeners )
		{
			dlg(new PrintContext(context), pageNr, printOperation);
		}
	}
	
	void delegate(PrintContext, PrintOperation)[] onEndPrintListeners;
	/**
	 * Emitted after all pages have been rendered.
	 * A handler for this signal can clean up any resources that have
	 * been allocated in the "begin-print" handler.
	 * Since 2.10
	 */
	void addOnEndPrint(void delegate(PrintContext, PrintOperation) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)
	{
		if ( !("end-print" in connectedSignals) )
		{
			Signals.connectData(
			getStruct(),
			"end-print",
			cast(GCallback)&callBackEndPrint,
			cast(void*)this,
			null,
			connectFlags);
			connectedSignals["end-print"] = 1;
		}
		onEndPrintListeners ~= dlg;
	}
	extern(C) static void callBackEndPrint(GtkPrintOperation* operationStruct, GtkPrintContext* context, PrintOperation printOperation)
	{
		foreach ( void delegate(PrintContext, PrintOperation) dlg ; printOperation.onEndPrintListeners )
		{
			dlg(new PrintContext(context), printOperation);
		}
	}
	
	bool delegate(PrintContext, PrintOperation)[] onPaginateListeners;
	/**
	 * Emitted after the "begin-print" signal, but before
	 * the actual rendering starts. It keeps getting emitted until a connected
	 * signal handler returns TRUE.
	 * The ::paginate signal is intended to be used for paginating a document
	 * in small chunks, to avoid blocking the user interface for a long
	 * time. The signal handler should update the number of pages using
	 * gtk_print_operation_set_n_pages(), and return TRUE if the document
	 * has been completely paginated.
	 * If you don't need to do pagination in chunks, you can simply do
	 * it all in the ::begin-print handler, and set the number of pages
	 * from there.
	 * Since 2.10
	 */
	void addOnPaginate(bool delegate(PrintContext, PrintOperation) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)
	{
		if ( !("paginate" in connectedSignals) )
		{
			Signals.connectData(
			getStruct(),
			"paginate",
			cast(GCallback)&callBackPaginate,
			cast(void*)this,
			null,
			connectFlags);
			connectedSignals["paginate"] = 1;
		}
		onPaginateListeners ~= dlg;
	}
	extern(C) static gboolean callBackPaginate(GtkPrintOperation* operationStruct, GtkPrintContext* context, PrintOperation printOperation)
	{
		foreach ( bool delegate(PrintContext, PrintOperation) dlg ; printOperation.onPaginateListeners )
		{
			if ( dlg(new PrintContext(context), printOperation) )
			{
				return 1;
			}
		}
		
		return 0;
	}
	
	bool delegate(GtkPrintOperationPreview*, PrintContext, Window, PrintOperation)[] onPreviewListeners;
	/**
	 * Gets emitted when a preview is requested from the native dialog.
	 * The default handler for this signal uses an external viewer
	 * application to preview.
	 * To implement a custom print preview, an application must return
	 * TRUE from its handler for this signal. In order to use the
	 * provided context for the preview implementation, it must be
	 * given a suitable cairo context with gtk_print_context_set_cairo_context().
	 * The custom preview implementation can use
	 * gtk_print_operation_preview_is_selected() and
	 * gtk_print_operation_preview_render_page() to find pages which
	 * are selected for print and render them. The preview must be
	 * finished by calling gtk_print_operation_preview_end_preview()
	 * (typically in response to the user clicking a close button).
	 * Since 2.10
	 */
	void addOnPreview(bool delegate(GtkPrintOperationPreview*, PrintContext, Window, PrintOperation) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)
	{
		if ( !("preview" in connectedSignals) )
		{
			Signals.connectData(
			getStruct(),
			"preview",
			cast(GCallback)&callBackPreview,
			cast(void*)this,
			null,
			connectFlags);
			connectedSignals["preview"] = 1;
		}
		onPreviewListeners ~= dlg;
	}
	extern(C) static gboolean callBackPreview(GtkPrintOperation* operationStruct, GtkPrintOperationPreview* preview, GtkPrintContext* context, GtkWindow* parent, PrintOperation printOperation)
	{
		foreach ( bool delegate(GtkPrintOperationPreview*, PrintContext, Window, PrintOperation) dlg ; printOperation.onPreviewListeners )
		{
			if ( dlg(preview, new PrintContext(context), new Window(parent), printOperation) )
			{
				return 1;
			}
		}
		
		return 0;
	}
	
	void delegate(PrintContext, gint, PageSetup, PrintOperation)[] onRequestPageSetupListeners;
	/**
	 * Emitted once for every page that is printed, to give
	 * the application a chance to modify the page setup. Any changes
	 * done to setup will be in force only for printing this page.
	 * Since 2.10
	 */
	void addOnRequestPageSetup(void delegate(PrintContext, gint, PageSetup, PrintOperation) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)
	{
		if ( !("request-page-setup" in connectedSignals) )
		{
			Signals.connectData(
			getStruct(),
			"request-page-setup",
			cast(GCallback)&callBackRequestPageSetup,
			cast(void*)this,
			null,
			connectFlags);
			connectedSignals["request-page-setup"] = 1;
		}
		onRequestPageSetupListeners ~= dlg;
	}
	extern(C) static void callBackRequestPageSetup(GtkPrintOperation* operationStruct, GtkPrintContext* context, gint pageNr, GtkPageSetup* setup, PrintOperation printOperation)
	{
		foreach ( void delegate(PrintContext, gint, PageSetup, PrintOperation) dlg ; printOperation.onRequestPageSetupListeners )
		{
			dlg(new PrintContext(context), pageNr, new PageSetup(setup), printOperation);
		}
	}
	
	void delegate(PrintOperation)[] onStatusChangedListeners;
	/**
	 * Emitted at between the various phases of the print operation.
	 * See GtkPrintStatus for the phases that are being discriminated.
	 * Use gtk_print_operation_get_status() to find out the current
	 * status.
	 * Since 2.10
	 */
	void addOnStatusChanged(void delegate(PrintOperation) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0)
	{
		if ( !("status-changed" in connectedSignals) )
		{
			Signals.connectData(
			getStruct(),
			"status-changed",
			cast(GCallback)&callBackStatusChanged,
			cast(void*)this,
			null,
			connectFlags);
			connectedSignals["status-changed"] = 1;
		}
		onStatusChangedListeners ~= dlg;
	}
	extern(C) static void callBackStatusChanged(GtkPrintOperation* operationStruct, PrintOperation printOperation)
	{
		foreach ( void delegate(PrintOperation) dlg ; printOperation.onStatusChangedListeners )
		{
			dlg(printOperation);
		}
	}
	
	
	/**
	 * Creates a new GtkPrintOperation.
	 * Since 2.10
	 * Throws: ConstructionException GTK+ fails to create the object.
	 */
	public this ()
	{
		// GtkPrintOperation* gtk_print_operation_new (void);
		auto p = gtk_print_operation_new();
		if(p is null)
		{
			throw new ConstructionException("null returned by gtk_print_operation_new()");
		}
		this(cast(GtkPrintOperation*) p);
	}
	
	/**
	 * Sets whether the gtk_print_operation_run() may return
	 * before the print operation is completed. Note that
	 * some platforms may not allow asynchronous operation.
	 * Since 2.10
	 * Params:
	 * allowAsync =  TRUE to allow asynchronous operation
	 */
	public void setAllowAsync(int allowAsync)
	{
		// void gtk_print_operation_set_allow_async (GtkPrintOperation *op,  gboolean allow_async);
		gtk_print_operation_set_allow_async(gtkPrintOperation, allowAsync);
	}
	
	/**
	 * Call this when the result of a print operation is
	 * GTK_PRINT_OPERATION_RESULT_ERROR, either as returned by
	 * gtk_print_operation_run(), or in the "done" signal
	 * handler. The returned GError will contain more details on what went wrong.
	 * Since 2.10
	 * Throws: GException on failure.
	 */
	public void getError()
	{
		// void gtk_print_operation_get_error (GtkPrintOperation *op,  GError **error);
		GError* err = null;
		
		gtk_print_operation_get_error(gtkPrintOperation, &err);
		
		if (err !is null)
		{
			throw new GException( new ErrorG(err) );
		}
		
	}
	
	/**
	 * Makes default_page_setup the default page setup for op.
	 * This page setup will be used by gtk_print_operation_run(),
	 * but it can be overridden on a per-page basis by connecting
	 * to the "request-page-setup" signal.
	 * Since 2.10
	 * Params:
	 * defaultPageSetup =  a GtkPageSetup, or NULL
	 */
	public void setDefaultPageSetup(PageSetup defaultPageSetup)
	{
		// void gtk_print_operation_set_default_page_setup  (GtkPrintOperation *op,  GtkPageSetup *default_page_setup);
		gtk_print_operation_set_default_page_setup(gtkPrintOperation, (defaultPageSetup is null) ? null : defaultPageSetup.getPageSetupStruct());
	}
	
	/**
	 * Returns the default page setup, see
	 * gtk_print_operation_set_default_page_setup().
	 * Since 2.10
	 * Returns: the default page setup
	 */
	public PageSetup getDefaultPageSetup()
	{
		// GtkPageSetup* gtk_print_operation_get_default_page_setup  (GtkPrintOperation *op);
		auto p = gtk_print_operation_get_default_page_setup(gtkPrintOperation);
		if(p is null)
		{
			return null;
		}
		return new PageSetup(cast(GtkPageSetup*) p);
	}
	
	/**
	 * Sets the print settings for op. This is typically used to
	 * re-establish print settings from a previous print operation,
	 * see gtk_print_operation_run().
	 * Since 2.10
	 * Params:
	 * printSettings =  GtkPrintSettings, or NULL
	 */
	public void setPrintSettings(PrintSettings printSettings)
	{
		// void gtk_print_operation_set_print_settings  (GtkPrintOperation *op,  GtkPrintSettings *print_settings);
		gtk_print_operation_set_print_settings(gtkPrintOperation, (printSettings is null) ? null : printSettings.getPrintSettingsStruct());
	}
	
	/**
	 * Returns the current print settings.
	 * Note that the return value is NULL until either
	 * gtk_print_operation_set_print_settings() or
	 * gtk_print_operation_run() have been called.
	 * Since 2.10
	 * Returns: the current print settings of op.
	 */
	public PrintSettings getPrintSettings()
	{
		// GtkPrintSettings* gtk_print_operation_get_print_settings  (GtkPrintOperation *op);
		auto p = gtk_print_operation_get_print_settings(gtkPrintOperation);
		if(p is null)
		{
			return null;
		}
		return new PrintSettings(cast(GtkPrintSettings*) p);
	}
	
	/**
	 * Sets the name of the print job. The name is used to identify
	 * the job (e.g. in monitoring applications like eggcups).
	 * If you don't set a job name, GTK+ picks a default one by
	 * numbering successive print jobs.
	 * Since 2.10
	 * Params:
	 * jobName =  a string that identifies the print job
	 */
	public void setJobName(string jobName)
	{
		// void gtk_print_operation_set_job_name (GtkPrintOperation *op,  const gchar *job_name);
		gtk_print_operation_set_job_name(gtkPrintOperation, Str.toStringz(jobName));
	}
	
	/**
	 * Sets the number of pages in the document.
	 * This must be set to a positive number
	 * before the rendering starts. It may be set in a
	 * "begin-print" signal hander.
	 * Note that the page numbers passed to the
	 * "request-page-setup"
	 * and "draw-page" signals are 0-based, i.e. if
	 * the user chooses to print all pages, the last ::draw-page signal
	 * will be for page n_pages - 1.
	 * Since 2.10
	 * Params:
	 * nPages =  the number of pages
	 */
	public void setNPages(int nPages)
	{
		// void gtk_print_operation_set_n_pages (GtkPrintOperation *op,  gint n_pages);
		gtk_print_operation_set_n_pages(gtkPrintOperation, nPages);
	}
	
	/**
	 * Sets the current page.
	 * If this is called before gtk_print_operation_run(),
	 * the user will be able to select to print only the current page.
	 * Note that this only makes sense for pre-paginated documents.
	 * Since 2.10
	 * Params:
	 * currentPage =  the current page, 0-based
	 */
	public void setCurrentPage(int currentPage)
	{
		// void gtk_print_operation_set_current_page  (GtkPrintOperation *op,  gint current_page);
		gtk_print_operation_set_current_page(gtkPrintOperation, currentPage);
	}
	
	/**
	 * If full_page is TRUE, the transformation for the cairo context
	 * obtained from GtkPrintContext puts the origin at the top left
	 * corner of the page (which may not be the top left corner of the
	 * sheet, depending on page orientation and the number of pages per
	 * sheet). Otherwise, the origin is at the top left corner of the
	 * imageable area (i.e. inside the margins).
	 * Since 2.10
	 * Params:
	 * fullPage =  TRUE to set up the GtkPrintContext for the full page
	 */
	public void setUseFullPage(int fullPage)
	{
		// void gtk_print_operation_set_use_full_page  (GtkPrintOperation *op,  gboolean full_page);
		gtk_print_operation_set_use_full_page(gtkPrintOperation, fullPage);
	}
	
	/**
	 * Sets up the transformation for the cairo context obtained from
	 * GtkPrintContext in such a way that distances are measured in
	 * units of unit.
	 * Since 2.10
	 * Params:
	 * unit =  the unit to use
	 */
	public void setUnit(GtkUnit unit)
	{
		// void gtk_print_operation_set_unit (GtkPrintOperation *op,  GtkUnit unit);
		gtk_print_operation_set_unit(gtkPrintOperation, unit);
	}
	
	/**
	 * Sets up the GtkPrintOperation to generate a file instead
	 * of showing the print dialog. The indended use of this function
	 * is for implementing "Export to PDF" actions. Currently, PDF
	 * is the only supported format.
	 * "Print to PDF" support is independent of this and is done
	 * by letting the user pick the "Print to PDF" item from the list
	 * of printers in the print dialog.
	 * Since 2.10
	 * Params:
	 * filename =  the filename for the exported file
	 */
	public void setExportFilename(string filename)
	{
		// void gtk_print_operation_set_export_filename  (GtkPrintOperation *op,  const gchar *filename);
		gtk_print_operation_set_export_filename(gtkPrintOperation, Str.toStringz(filename));
	}
	
	/**
	 * If show_progress is TRUE, the print operation will show a
	 * progress dialog during the print operation.
	 * Since 2.10
	 * Params:
	 * showProgress =  TRUE to show a progress dialog
	 */
	public void setShowProgress(int showProgress)
	{
		// void gtk_print_operation_set_show_progress  (GtkPrintOperation *op,  gboolean show_progress);
		gtk_print_operation_set_show_progress(gtkPrintOperation, showProgress);
	}
	
	/**
	 * If track_status is TRUE, the print operation will try to continue report
	 * on the status of the print job in the printer queues and printer. This
	 * can allow your application to show things like "out of paper" issues,
	 * and when the print job actually reaches the printer.
	 * This function is often implemented using some form of polling, so it should
	 * not be enabled unless needed.
	 * Since 2.10
	 * Params:
	 * trackStatus =  TRUE to track status after printing
	 */
	public void setTrackPrintStatus(int trackStatus)
	{
		// void gtk_print_operation_set_track_print_status  (GtkPrintOperation *op,  gboolean track_status);
		gtk_print_operation_set_track_print_status(gtkPrintOperation, trackStatus);
	}
	
	/**
	 * Sets the label for the tab holding custom widgets.
	 * Since 2.10
	 * Params:
	 * label =  the label to use, or NULL to use the default label
	 */
	public void setCustomTabLabel(string label)
	{
		// void gtk_print_operation_set_custom_tab_label  (GtkPrintOperation *op,  const gchar *label);
		gtk_print_operation_set_custom_tab_label(gtkPrintOperation, Str.toStringz(label));
	}
	
	/**
	 * Runs the print operation, by first letting the user modify
	 * print settings in the print dialog, and then print the document.
	 * Normally that this function does not return until the rendering of all
	 * pages is complete. You can connect to the
	 * "status-changed" signal on op to obtain some
	 * information about the progress of the print operation.
	 * Furthermore, it may use a recursive mainloop to show the print dialog.
	 * If you call gtk_print_operation_set_allow_async() or set the
	 * "allow-async" property the operation will run
	 * asynchronously if this is supported on the platform. The
	 * "done" signal will be emitted with the result of the
	 * operation when the it is done (i.e. when the dialog is canceled, or when
	 * the print succeeds or fails).
	 * if (settings != NULL)
	 *  gtk_print_operation_set_print_settings (print, settings);
	 * if (page_setup != NULL)
	 *  gtk_print_operation_set_default_page_setup (print, page_setup);
	 * g_signal_connect (print, "begin-print",
	 *  G_CALLBACK (begin_print), data);
	 * g_signal_connect (print, "draw-page",
	 *  G_CALLBACK (draw_page), data);
	 * res = gtk_print_operation_run (print,
	 *  GTK_PRINT_OPERATION_ACTION_PRINT_DIALOG,
	 *  parent,
	 *  error);
	 * if (res == GTK_PRINT_OPERATION_RESULT_ERROR)
	 *  {
		 *  error_dialog = gtk_message_dialog_new (GTK_WINDOW (parent),
		 *  			 GTK_DIALOG_DESTROY_WITH_PARENT,
		 * 					 GTK_MESSAGE_ERROR,
		 * 					 GTK_BUTTONS_CLOSE,
		 * 					 "Error printing file:\n%s",
		 * 					 error->message);
		 *  g_signal_connect (error_dialog, "response",
		 *  G_CALLBACK (gtk_widget_destroy), NULL);
		 *  gtk_widget_show (error_dialog);
		 *  g_error_free (error);
	 *  }
	 * else if (res == GTK_PRINT_OPERATION_RESULT_APPLY)
	 *  {
		 *  if (settings != NULL)
		 * g_object_unref (settings);
		 *  settings = g_object_ref (gtk_print_operation_get_print_settings (print));
	 *  }
	 * Note that gtk_print_operation_run() can only be called once on a
	 * given GtkPrintOperation.
	 * Since 2.10
	 * Params:
	 * action =  the action to start
	 * parent =  Transient parent of the dialog, or NULL
	 * Returns: the result of the print operation. A return value of  GTK_PRINT_OPERATION_RESULT_APPLY indicates that the printing was completed successfully. In this case, it is a good idea to obtain  the used print settings with gtk_print_operation_get_print_settings()  and store them for reuse with the next print operation. A value of GTK_PRINT_OPERATION_RESULT_IN_PROGRESS means the operation is running asynchronously, and will emit the "done" signal when  done.
	 * Throws: GException on failure.
	 */
	public GtkPrintOperationResult run(GtkPrintOperationAction action, Window parent)
	{
		// GtkPrintOperationResult gtk_print_operation_run (GtkPrintOperation *op,  GtkPrintOperationAction action,  GtkWindow *parent,  GError **error);
		GError* err = null;
		
		auto p = gtk_print_operation_run(gtkPrintOperation, action, (parent is null) ? null : parent.getWindowStruct(), &err);
		
		if (err !is null)
		{
			throw new GException( new ErrorG(err) );
		}
		
		return p;
	}
	
	/**
	 * Cancels a running print operation. This function may
	 * be called from a "begin-print",
	 * "paginate" or "draw-page"
	 * signal handler to stop the currently running print
	 * operation.
	 * Since 2.10
	 */
	public void cancel()
	{
		// void gtk_print_operation_cancel (GtkPrintOperation *op);
		gtk_print_operation_cancel(gtkPrintOperation);
	}
	
	/**
	 * Returns the status of the print operation.
	 * Also see gtk_print_operation_get_status_string().
	 * Since 2.10
	 * Returns: the status of the print operation
	 */
	public GtkPrintStatus getStatus()
	{
		// GtkPrintStatus gtk_print_operation_get_status (GtkPrintOperation *op);
		return gtk_print_operation_get_status(gtkPrintOperation);
	}
	
	/**
	 * Returns a string representation of the status of the
	 * print operation. The string is translated and suitable
	 * for displaying the print status e.g. in a GtkStatusbar.
	 * Use gtk_print_operation_get_status() to obtain a status
	 * value that is suitable for programmatic use.
	 * Since 2.10
	 * Returns: a string representation of the status of the print operation
	 */
	public string getStatusString()
	{
		// const gchar* gtk_print_operation_get_status_string  (GtkPrintOperation *op);
		return Str.toString(gtk_print_operation_get_status_string(gtkPrintOperation));
	}
	
	/**
	 * A convenience function to find out if the print operation
	 * is finished, either successfully (GTK_PRINT_STATUS_FINISHED)
	 * or unsuccessfully (GTK_PRINT_STATUS_FINISHED_ABORTED).
	 * Note: when you enable print status tracking the print operation
	 * can be in a non-finished state even after done has been called, as
	 * the operation status then tracks the print job status on the printer.
	 * Since 2.10
	 * Returns: TRUE, if the print operation is finished.
	 */
	public int isFinished()
	{
		// gboolean gtk_print_operation_is_finished (GtkPrintOperation *op);
		return gtk_print_operation_is_finished(gtkPrintOperation);
	}
	
	/**
	 * Runs a page setup dialog, letting the user modify the values from
	 * page_setup. If the user cancels the dialog, the returned GtkPageSetup
	 * is identical to the passed in page_setup, otherwise it contains the
	 * modifications done in the dialog.
	 * Note that this function may use a recursive mainloop to show the page
	 * setup dialog. See gtk_print_run_page_setup_dialog_async() if this is
	 * a problem.
	 * Since 2.10
	 * Params:
	 * parent =  transient parent, or NULL
	 * pageSetup =  an existing GtkPageSetup, or NULL
	 * settings =  a GtkPrintSettings
	 * Returns: a new GtkPageSetup
	 */
	public static PageSetup gtkPrintRunPageSetupDialog(Window parent, PageSetup pageSetup, PrintSettings settings)
	{
		// GtkPageSetup* gtk_print_run_page_setup_dialog (GtkWindow *parent,  GtkPageSetup *page_setup,  GtkPrintSettings *settings);
		auto p = gtk_print_run_page_setup_dialog((parent is null) ? null : parent.getWindowStruct(), (pageSetup is null) ? null : pageSetup.getPageSetupStruct(), (settings is null) ? null : settings.getPrintSettingsStruct());
		if(p is null)
		{
			return null;
		}
		return new PageSetup(cast(GtkPageSetup*) p);
	}
	
	/**
	 * Runs a page setup dialog, letting the user modify the values from page_setup.
	 * In contrast to gtk_print_run_page_setup_dialog(), this function returns after
	 * showing the page setup dialog on platforms that support this, and calls done_cb
	 * from a signal handler for the ::response signal of the dialog.
	 * Since 2.10
	 * Params:
	 * parent =  transient parent, or NULL
	 * pageSetup =  an existing GtkPageSetup, or NULL
	 * settings =  a GtkPrintSettings
	 * doneCb =  a function to call when the user saves the modified page setup
	 * data =  user data to pass to done_cb
	 */
	public static void gtkPrintRunPageSetupDialogAsync(Window parent, PageSetup pageSetup, PrintSettings settings, GtkPageSetupDoneFunc doneCb, void* data)
	{
		// void gtk_print_run_page_setup_dialog_async  (GtkWindow *parent,  GtkPageSetup *page_setup,  GtkPrintSettings *settings,  GtkPageSetupDoneFunc done_cb,  gpointer data);
		gtk_print_run_page_setup_dialog_async((parent is null) ? null : parent.getWindowStruct(), (pageSetup is null) ? null : pageSetup.getPageSetupStruct(), (settings is null) ? null : settings.getPrintSettingsStruct(), doneCb, data);
	}
}
