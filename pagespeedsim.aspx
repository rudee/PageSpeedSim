<%@ Page Language="C#" %><%
string filename    = "pagespeedsim.aspx";

string cssAlphabet = @" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{}():,;-_.%#""";
string jsAlphabet  = @" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{}():,;-_.%#""";

string type = Request.QueryString["type"];

var cssLinks = new List<string>();
var jsLinks  = new List<string>();
var pngLinks = new List<string>();
var jpgLinks = new List<string>();

Func<string, long> getSize = urlParam => {
    if (string.IsNullOrWhiteSpace(urlParam))
    {
        return 0;
    }
    string val          = System.Text.RegularExpressions.Regex.Match(urlParam, @"[\d]+\.?[\d]*").ToString();
    double sizeAsDouble = 0;
    double.TryParse(val, out sizeAsDouble);
    string unit = System.Text.RegularExpressions.Regex.Match(urlParam, @"[a-z]*$").ToString();
    switch (unit)
    {
        case "b":
            return (long)Math.Ceiling(sizeAsDouble);
        case "mb":
            return (long)Math.Ceiling(sizeAsDouble * 1024 * 1024);
        default: // "kb"
            return (long)Math.Ceiling(sizeAsDouble * 1024);
    }
};

switch (type)
{
    case "html":
        {
            // css
            string cssParam = Request.QueryString["css"];
            if (!string.IsNullOrWhiteSpace(cssParam))
            {
                string[] cssParams = cssParam.Split(new[] { ',' });
                foreach (string css in cssParams)
                {
                    // e.g. css = "1kb png2kb jpg3kb"
                    string[] cssLinkAttrs = css.Split(new[] { ' ' });
                    string   cssLink      = "type=css";
                    bool     sizeIsSet    = false;
                    foreach (string cssLinkAttr in cssLinkAttrs)
                    {
                        if (cssLinkAttr.StartsWith("png"))
                        {
                            cssLink += "&png=" + cssLinkAttr.Substring(3);
                        }
                        else if (cssLinkAttr.StartsWith("jpg"))
                        {
                            cssLink += "&jpg=" + cssLinkAttr.Substring(3);
                        }
                        else if (!sizeIsSet && !string.IsNullOrWhiteSpace(cssLinkAttr))
                        {
                            sizeIsSet = true;
                            cssLink += "&size=" + cssLinkAttr;
                        }
                    }
                    cssLinks.Add(cssLink);
                }
            }

            // js
            string jsParam = Request.QueryString["js"];
            if (!string.IsNullOrWhiteSpace(jsParam))
            {
                string[] jsParams = jsParam.Split(new[] { ',' });
                foreach (string js in jsParams)
                {
                    // e.g. js = "1kb"
                    jsLinks.Add("type=js&size=" + js);
                }
            }

            // png
            string pngParam = Request.QueryString["png"];
            if (!string.IsNullOrWhiteSpace(pngParam))
            {
                string[] pngParams = pngParam.Split(new[] { ',' });
                foreach (string png in pngParams)
                {
                    // e.g. png = "1kb"
                    pngLinks.Add("type=png&size=" + png);
                }
            }

            // jpg
            string jpgParam = Request.QueryString["jpg"];
            if (!string.IsNullOrWhiteSpace(jpgParam))
            {
                string[] jpgParams = jpgParam.Split(new[] { ',' });
                foreach (string jpg in jpgParams)
                {
                    // e.g. jpg = "1kb"              
                    jpgLinks.Add("type=jpg&size=" + jpg);
                }
            }
        }
        break;

    case "css": // e.g. ?type=css&size=1kb&png=2kb&jpg=3kb"
        {
            Response.ContentType = "text/css";

            string pngParam = Request.QueryString["png"];
            if (!string.IsNullOrWhiteSpace(pngParam))
            {
                string[] pngParams = pngParam.Split(new[] { ',' });
                for (int i = 0; i < pngParams.Length; i++)
                {
                    // e.g. png = "1kb"
                    Response.Write("div.png" + i
                                   + System.Environment.NewLine + "{"
                                   + System.Environment.NewLine + "  background-image: url(\"" + filename + "?type=png&size=" + pngParams[i] + "\")"
                                   + System.Environment.NewLine + "}"
                                   + System.Environment.NewLine);
                }
            }

            string jpgParam = Request.QueryString["jpg"];
            if (!string.IsNullOrWhiteSpace(jpgParam))
            {
                string[] jpgParams = jpgParam.Split(new[] { ',' });
                for (int i = 0; i < jpgParams.Length; i++)
                {
                    // e.g. jpg = "1kb"
                    Response.Write("div.jpg" + i
                                   + System.Environment.NewLine + "{"
                                   + System.Environment.NewLine + "  background-image: url(\"" + filename + "?type=jpg&size=" + jpgParams[i] + "\")"
                                   + System.Environment.NewLine + "}"
                                   + System.Environment.NewLine);
                }
            }

            Response.Write(System.Environment.NewLine + "/*" + System.Environment.NewLine);
            long sizeInBytes = getSize(Request.QueryString["size"]);
            var r = new Random();
            for (long l = 0; l < sizeInBytes; l++)
            {
                Response.Write(cssAlphabet[r.Next(cssAlphabet.Length)]);
            }
            Response.Write(System.Environment.NewLine + "*/");
        }
        return;

    case "js":
        {
            long sizeInBytes = getSize(Request.QueryString["size"]);
            var r = new Random();
            Response.ContentType = "application/javascript";
            for (long l = 0; l < sizeInBytes; l++)
            {
                Response.Write(jsAlphabet[r.Next(jsAlphabet.Length)]);
            }
        }
        return;

    case "png":
    case "jpg":
        {
            long sizeInBytes = getSize(Request.QueryString["size"]);
            switch (type)
            {
                case "png":
                case "jpg":
                    if (sizeInBytes < 1024)
                    {
                        sizeInBytes = 1024;
                    }
                    long sizeInKb = (long)Math.Ceiling((double)sizeInBytes / 1024);
                    byte[] b;
            
                    switch (type)
                    {
                        case "png":
                            Response.ContentType = "image/png";
                            break;
                        case "jpg":
                            Response.ContentType = "image/jpeg";
                            break;
                    }
                    Response.BinaryWrite(new byte[sizeInBytes]);
                    break;
            }
        }
        //Response.End();
        //break;
        return;
    default:
        //Response.End();
        //return;
        break;
}
%><!DOCTYPE html>
<html>
<head>
<title>Page Speed Sim</title>
<%
foreach (string cssLink in cssLinks)
{
    %><link rel="stylesheet" href="<%= filename %>?<%= cssLink %>">
<%
}
%>
</head>
<body>
<p>type: "<%= Request.QueryString["type"]%>"</p>
<p>size: "<%= Request.QueryString["size"]%>"</p>
<p>attr: "<%= Request.QueryString["attr"]%>"</p>
<p>css: "<%= Request.QueryString["css"]%>"</p>
<p>js: "<%= Request.QueryString["js"]%>"</p>
<p>png: "<%= Request.QueryString["png"]%>"</p>
<p>jpg: "<%= Request.QueryString["jpg"]%>"</p>

<%
foreach (string pngLink in pngLinks)
{
    %><img src="<%= filename %>?<%= pngLink %>"/>
<%
}
%>

<%
foreach (string jpgLink in jpgLinks)
{
    %><img src="<%= filename %>?<%= jpgLink %>"/>
<%
}
%>

<%
foreach (string jsLink in jsLinks)
{
    %><script type="text/javascript" src="<%= filename %>?<%= jsLink %>"></script>
<%
}
%>
</body>
</html>