module sitemap;
import std.string;
import std.conv : to;
import std.uri : uriLength;
import std.datetime : DateTime;
import std.typecons : Nullable;
import std.exception : enforce;

private string escapeUrl(string url)
{
	return translate(url, [
			'&': "&amp;",
			'\'': "&apos;",
			'"': "&quot;",
			'>': "&gt;",
			'<': "&lt;"
		]);
}

/// Sitemap builder
/// Reference: https://www.sitemaps.org/protocol.html
class Sitemap
{
	SitemapUrl[] urls;
	
	// Reference: https://www.w3.org/TR/NOTE-datetime
	string toW3CDatetimeString(DateTime d)
	{
		return d.toISOExtString() ~ "Z";
	}

	string build(bool pretty = false)
	{
		string str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		if (pretty)
			str ~= "\n";
		str ~= "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">";
		if (pretty)
			str ~= "\n";

		enforce(urls.length > 0, "Sitemap must have at least one URL");
		foreach (u; urls)
		{
			enforce(uriLength(u.loc) > 0, "Sitemap location must be a URL");
			if (pretty)
				str ~= "\t";
			str ~= "<url>";
			if (pretty)
				str ~= "\n";

			if (pretty)
				str ~= "\t\t";
			str ~= "<loc>" ~ escapeUrl(u.loc) ~ "</loc>";
			if (pretty)
				str ~= "\n";

			if (!u.lastmod.isNull)
			{
				if (pretty)
					str ~= "\t\t";

				DateTime dat = u.lastmod.get;
				str ~= "<lastmod>" ~ toW3CDatetimeString(dat) ~ "</lastmod>";

				if (pretty)
					str ~= "\n";
			}

			if (u.changefreq != ChangeFrequency.NotSet)
			{
				if (pretty)
					str ~= "\t\t";
				str ~= "<changefreq>" ~ u.changefreq.to!string().toLower ~ "</changefreq>";
				if (pretty)
					str ~= "\n";
			}

			enforce(u.priority >= 0 && u.priority <= 1, "Sitemap priority must be between 0.0 and 1.0");

			if (u.priority != 0.5f)
			{
				if (pretty)
					str ~= "\t\t";
				str ~= "<priority>" ~ u.priority.to!string() ~ "</priority>";
				if (pretty)
					str ~= "\n";
			}

			if (pretty)
				str ~= "\t";
			str ~= "</url>";
			if (pretty)
				str ~= "\n";
		}

		str ~= "</urlset>";

		return str;
	}
}

/// Entry in the sitemap
class SitemapUrl
{
	/// Required.
	/// URL of the page. This URL must begin with the protocol (such as http) and end with a trailing slash, if your web server requires it. This value must be less than 2,048 characters.
	string loc;
	/// Optional.
	/// The date of last modification of the file.
	Nullable!DateTime lastmod;
	/// Optional.
	/// How frequently the page is likely to change. This value provides general information to search engines and may not correlate exactly to how often they crawl the page.
	/// The value Always should be used to describe documents that change each time they are accessed. The value Never should be used to describe archived URLs.
	ChangeFrequency changefreq = ChangeFrequency.NotSet;
	/// Optional.
	/// The priority of this URL relative to other URLs on your site. Valid values range from 0.0 to 1.0. This value does not affect how your pages are compared to pages on other sites—it only lets the search engines know which pages you deem most important for the crawlers.
	/// The default priority of a page is 0.5.
	float priority = 0.5f;
}

enum ChangeFrequency
{
	NotSet,
	Always,
	Hourly,
	Daily,
	Weekly,
	Monthly,
	Yearly,
	Never
}
