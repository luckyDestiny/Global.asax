<%@ Application Language="C#" %>
<%@ Import Namespace="System.Web.Optimization" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Web.Configuration" %>
<%@ Import Namespace="System.IO.Compression" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">

    private static NLog.Logger logger = NLog.LogManager.GetCurrentClassLogger();
    void Application_Start(object sender, EventArgs e)
    {     
        BundleConfig.RegisterBundles(BundleTable.Bundles);
        JsCssBundleConfig.RegisterBundles(BundleTable.Bundles);  
    }

    void Application_End(object sender, EventArgs e)
    {
      

    }

    void Application_Error(object sender, EventArgs e)
    {
       
        string err="";
        try
        {
            Exception ex = Server.GetLastError().InnerException;
        }
        catch
        {

        }


        try
        {
            Response.Filter = null;
        }
        catch
        {
        }

    }

    void Session_Start(object sender, EventArgs e)
    {
        

    }

    void Session_End(object sender, EventArgs e)
    {
        
       

    }

    void Application_PreRequestHandlerExecute(object sender, EventArgs e)
    {
       
        HttpRequest request = HttpContext.Current.Request;
        if(request.Path.ToLower().StartsWith("/some/")==false)
            CompressS.CompressPage(sender as HttpApplication);
        
    }

    void Application_PostReleaseRequestState(object sender, EventArgs e)
    {
        
    }

    void Application_EndRequest(object sender, EventArgs e)
    {
       
        foreach(string item in  Response.Cookies)
        {
          
            Response.Cookies[item].HttpOnly = true;
        }

    }

    void Application_PreSendRequestHeaders(object sender, EventArgs e)
    {
       
        Response.Headers.Remove("Server");
        Response.Headers.Remove("X-AspNet-Version");
        Response.Headers.Remove("X-Powered-By");
        Response.Headers.Remove("X-AspNetMvc-Version");
        Response.Headers.Remove("Server");
    }

    protected void Application_BeginRequest(object sender, EventArgs e)
    {
       
    }

    void Application_AcquireRequestState(object sender, EventArgs e)
    {
       
        string url = Request.RawUrl.ToLower();
        string path = Request.FilePath.ToLower();

        List<string> list = new List<string>() {
                                                 "/Login.aspx".ToLower()
                                                 
                                               };

        if (list.Contains(path) == false)
        {
            if (path.StartsWith("/bundles/") == false && path.StartsWith("/login/") == false)
            {
                if (path.EndsWith(".aspx") || path.EndsWith(".js"))
                {
                    AuthServer.CheckLogin();
                }
            }

          
        }

        if (url.Contains("/home.aspx?"))
        {
            SessionS.AddSession("tempUrl", url);
        }
    }

    private void HttpCompress(HttpApplication app)
    {
        string acceptEncoding = app.Request.Headers["Accept-Encoding"];
        Stream prevUncompressedStream = app.Response.Filter;


        if (!(app.Context.CurrentHandler is Page) || app.Request["HTTP_X_MICROSOFTAJAX"] != null)
            return;


        if (string.IsNullOrEmpty(acceptEncoding))
            return;


        acceptEncoding = acceptEncoding.ToLower();


        if ((acceptEncoding.Contains("deflate") || acceptEncoding == "*") && CompressScript(Request.ServerVariables["SCRIPT_NAME"]))
        {
            // deflate
            app.Response.Filter = new DeflateStream(prevUncompressedStream,CompressionMode.Compress);
            app.Response.AppendHeader("Content-Encoding", "deflate");
        }
        else if (acceptEncoding.Contains("gzip")&& CompressScript(Request.ServerVariables["SCRIPT_NAME"]))
        {
            // gzip
            app.Response.Filter = new GZipStream(prevUncompressedStream,CompressionMode.Compress);
            app.Response.AppendHeader("Content-Encoding", "gzip");
        }
    }


    private static bool CompressScript(string scriptName)
    {
        if (scriptName.ToLower().Contains(".axd")) return false;
        return true;
    }
</script>
