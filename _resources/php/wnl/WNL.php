<?php


/**
 * The WNL class uses PHP's built in simplexml_load_file function to open the file.
 * It uses xpath to get the collection of items you want.
 */
class WNL extends XmlCollection {
    var $wnl;
    var $dataClass;
    var $dataType;
    var $url;
    var $xml;
    // All item Objects are "copied" to $items
    //   [Note] PHP default: objects are copied by reference
    //   [Note] Modifying an item/object in $items will modify the original
    //   [Note] $items is simply intended for ordering purposes
    // For whatever reason, if someone needs the unordered original...
    var $items;
    var $itemsOriginal;

    var $indexedCategories;

    var $page;
    var $totalPages;

    // var $Count;
    var $isGood;
    var $exceptions = array();

    /**
     * Constructor for the WNL class
     *
     * @param $_url    url to the RSS feed to be parsed.
     * @param $_xpath  [Optional] The xpath to each RSS item in the feed.
     * @param $_class  [Optional] The class name to be used for parsing the item
     * @param $_type   [Optional] The type of data used
     */
    function __construct($_url,$_xpath = "/rss/channel/item",$_class = "CategoryRssItem",$_type = "xml") {
        $this->dataClass = $_class;
        $this->dataType = $_type;

        try {
            if(!strncmp($_url, "/", strlen("/")) == 1 && ($_url != "//")) {
                $wnl = simplexml_load_file($_SERVER['DOCUMENT_ROOT'].$_url,'SimpleXMLElement', LIBXML_NOCDATA);
            } else {
                $wnl = simplexml_load_file($_url,'SimpleXMLElement', LIBXML_NOCDATA);
            }
        }
        catch(Exception $e) {
            $this->exceptions[] = $e;
            throw new Exception("Could not load xml exception", 0, $e);
            $this->isGood = FALSE;
        }

        if($wnl) {
            $this->xml = $wnl;
            $this->itemsOriginal = $wnl->xpath($_xpath);
            // Make copy for reordering
            // [Min overhead] PHP default: Objects (each item) copied reference
            $this->items = $this->itemsOriginal;
            $this->isGood = TRUE;
            // $this->Count = count($this->items);
        } else {
            $this->exceptions[] = "No Wnl Object";
            $this->isGood = FALSE;
        }

        // $this->Count = count($this->items);
    } // end Construct


    /***************************************
     * START Pagination
     ***************************************/
    function paginate($amount_per_page = 10) {
        try {
            if (isset($this->page) || isset($this->total_pages)) {
                throw new Exception("The paginate() function has already been called!");
            }

            $total_items = count($this->items);
            $total_pages = ceil($total_items / $amount_per_page);

            // Get page number from URL, sanitize and validate
            $page = filter_input(INPUT_GET, "page", FILTER_SANITIZE_NUMBER_INT);
            $page = filter_var($page, FILTER_VALIDATE_INT, array('options' => array('default' => 1) ));

            // Fix page range
            if ($page < 1) {
                $page = 1;
            } else if ($page > $total_pages) {
                $page = $total_pages;
            }

            $offset = ($page-1) * $amount_per_page;
            // Set Class Properties
            $this->page = $page;
            $this->totalPages = $total_pages;
            $this->items = $this->take($amount_per_page, $offset);

        } catch(Exception $e) {
            $this->exceptions[] = __METHOD__ . ' > ' . $e->getMessage();
        }
        return $this;
    }

    // Output a Paginated page's Navigation
    function paginateNavigation($delegate = NULL, $page_range = 7) {
        try {
            // Check if required class properties ($page and $total_pages) have been set.
            // If not, then we know paginate() has not been called... Trigger Exception
            if ( !isset($this->page) || !isset($this->totalPages)) {
                throw new Exception("The paginate() function must first be called");
            }
            if (!is_callable($delegate)) {
                $delegate = array($this, 'defaultPaginationLink');
                $this->exceptions[] = __METHOD__ . ' > Delegate function is not callable, using default.';
            }
            
            //////////////////////////////
            // START Visible Pagination Logic
            //////////////////////////////
            if ($page_range < 3)
                $page_range = 3; // min
            if ($page_range > $this->totalPages)
                $page_range = $this->totalPages; // max
            
            $page_left  = floor(($page_range-1)/2);
            $page_right = ceil( ($page_range-1)/2);

            $page_start = $this->page - $page_left;
            $page_end   = $this->page + $page_right;

            $shift = 0; // accommodate under/over
            if ($page_end > $this->totalPages) $shift += $this->totalPages - $page_end;
            if ($page_start < 1)               $shift += 1 - $page_start;

            $page_start += $shift;
            $page_end   += $shift;
            //////////////////////////////
            // END Visible Pagination Logic
            //////////////////////////////
            

            // Before Navigation Links
            if( $this->page > 1 ) { // if > first page
                $this->buildPaginationLink($delegate, $this->page - 1, ''); // Previous Page
                
                if( $page_start > 1 ) { // if > second page
                    $this->buildPaginationLink($delegate, 1, 1); // First Page Number
                    $this->buildPaginationLink($delegate, $page_start, '...'); // Elipsis
                }
            } else {
                $delegate('#', '', '', ''); // Disabled Previous Page
            }
            
            // Navigation Links
            for ($i=$page_start; $i < $page_end+1; $i++) {
                $class = ($i == $this->page)? ' class="active"' : '';
                // float vs int
                $this->buildPaginationLink($delegate, $i, $i, $class); // Page Number
            }

            // After Navigation Links
            if( $this->page < $this->totalPages ) { // if < last page
                if( $page_end < $this->totalPages ) { // if < 2nd last page
                    $this->buildPaginationLink($delegate, $page_end, '...'); // Elipsis
                    $this->buildPaginationLink($delegate, $this->totalPages, $this->totalPages); // Last Page Number
                }
                
                $this->buildPaginationLink($delegate, $this->page+1, ''); // Next Page
            } else {
                $delegate('#', '', '', ''); // Disabled Next Page
            }
        } catch(Exception $e) {
            $this->exceptions[] = __METHOD__ . ' > ' . $e->getMessage();
        }
        return $this;
    }

    function buildPaginationLink($delegate, $page_number, $text, $class = '') {
        $url = strtok($_SERVER["REQUEST_URI"],'?');
        $query = $_GET;
        $query['page'] = $page_number;
        $query_string = '?' . http_build_query($query, '', '&amp;');

        $delegate($url, $query_string, $text, $class);
    }

    // Pagination user defined $delegate function
    function defaultPaginationLink($url, $query_string, $text, $class) {
        echo "<li><a href='{$url}{$query_string}'{$class}>{$text}</a></li>";
    }
    /***************************************
     * END Pagination
     ***************************************/

    function getFromCSV( $str ) {
        $cat = array_map('trim', explode(',', $str));
        return array_filter($cat); // Remove all empty elements
    }


    /**
     * The genericFilter function filters items using a user supplied function.
     * @param $delegate  User defined function used for filtering
     * @param $filter    One or more values to filter by
     * return object()   Returns WNL object
     */
    function genericFilter( $delegate, $filter = NULL ) {
        try {

            if (!is_callable($delegate)) {
                throw new Exception("Delegate function is required");
            }

            if (!empty($filter)) {
                $filtered = array_filter(
                    $this->items,
                    // PHP 5.3.0 : Anonymous functions become available.
                    function ($item) use ($delegate, $filter) {
                        // if you get the error:
                        // "Fatal error: Function name must be a string in..."
                        // then use Option 1.

                        // Option 1: PHP Version >= 5.3
                        // return call_user_func($delegate, $item, $filter);

                        // Option 2: PHP Version >= 5.4
                        return $delegate($item, $filter);
                    }
                );
                $this->items = $filtered;
            }
        } catch(Exception $e) {
            $this->exceptions[] = __METHOD__ . ' > ' . $e->getMessage();
        }
        return $this;
    }


    function categoryFilter( $cat = NULL ) {
        try {
            // default get from url
            if ( !isset($cat) )
                $cat = isset($_GET['cat'])? $_GET['cat'] : NULL;

            if ( is_string($cat) )
                $cat = $this->getFromCSV( $cat );

            if ( !is_array($cat) )
                throw new Exception("Categories must be an array.");

            // Defaults to all. All means do nothing
            if ( is_array($cat) && !empty($cat) && strtolower($cat[0]) !== "all" ) {
                $this->genericFilter(array($this, 'isInCats'), $cat);
            }
        } catch(Exception $e) {
            $this->exceptions[] = __METHOD__ . ' > Exception while filtering categories';
        }
        return $this;
    }


    /**
     * IsInCats
     * Check if any item's have categories within the given categories list.
     * @param $item  The item to have it's categories checked.
     * @param $cat   The category list that the item will be compared against.
     * return bool   Returns true if at least one category match.
     */
    function isInCats($item, $cat) {
        if (!is_array($cat)) {
            $cat = $this->getFromCSV($cat);
        }
        // get the categories from the given item
        $y = new $this->dataClass($item);
        $categories = $y->category;

        // check if it's in the category given
        $catsFound = array_intersect($categories, $cat);

        return !empty($catsFound);
    }


    /**
     * The GetCatsFromUrl function returns all the categories that are associated with the feed item that matches the given url.
     * @param $url    The url used to find the current item in the feed.
     * return array(string)   The categories associated with the item found in the feed. If no item is found, returns all categories.
     */
    function getCatsFromUrl($url) {
        foreach ($this->items as $item) {
            $y = new $this->dataClass($item);
            // check if we found the item for the current page
            if ($y->link == $url) {
                return $y->category; // return array of categories for the current item
            }
        }
        return array("All"); // return all categories if item not found
    }

    // Include the category "All"
    function indexCategories($include_all = true) {
        try {
            $categoryList = array();
            // loop through all items to get unique categories
            foreach ($this->items as $item) {
                $y = new $this->dataClass($item);
                // create array of categories for the current item
                $categoryList[] = $y->category;
            }
            $categoryList = array_unique(call_user_func_array('array_merge', $categoryList));

            // sort category list alphabetically
            asort($categoryList);

            if ($include_all) {
                array_unshift($categoryList, 'All');
            }

            $this->indexedCategories = $categoryList;
        }
        catch(Exception $e) {
            echo('<p> wnl.php - Exception while indexing categories</p>');
        }
        return $this;
    }

    /**
     * The DisplayCategories function displays all unique categories in the feed as list items.
     */
    function displayCategories($delegate = null) {
        // if categories have not been indexed, index them
        if ( !isset($this->indexedCategories) ) {
            $this->indexCategories();
        }

        try {
            // delegate callback default
            if (!is_callable($delegate)) {
                $delegate = array($this, 'displayCategoriesDefault');
                $this->exceptions[] = __METHOD__ . ' > Delegate function is not callable, using default.';
            }

            array_map($delegate, $this->indexedCategories); // display all categories
        }
        catch(Exception $e) {
            echo('<p> wnl.php - Exception while displaying categories</p>');
        }
    }

    function displayCategoriesDefault($category) {
        echo '<li><a href="' . strtok($_SERVER["REQUEST_URI"],'?') . '?cat=' . $category . '">' . $category . '</a></li>';
    }

    function displayNewsBoardCategoriesDefault($category) {
        echo '<li><a href="#" data-filter=".' . strtolower($category) . '">' . $category . '</a></li>';
    }

    /**
     * The DisplayNewsBoardCategories function displays a list of categories that are being used in the RSS items.
     */
    function displayNewsBoardCategories() {
        $this->displayCategories(array($this, 'displayNewsBoardCategoriesDefault'));
    }

    function take($qty = 'All', $offset = 0) {
        return $this->takeFrom($qty, $offset, $this->items);
    }
    function takeFrom($qty, $offset, $items) {
        $max_qty = count($items) - $offset;
        // [DEV] Will array_slice error if items requested are more than exist?
        if ( strtolower($qty)==='all' || $qty>$max_qty ) {
            $qty = $max_qty;
        }
        return array_slice($items, $offset, $qty);
    }

    //  byNodeValue returns items that have a specified node value
    // $newArrayOfNodesWithTheSameValue = $wnl->byNodeValue("category","athletics"); - $newArrayOfNodesWithTheSameValue will contain items in which the <category> node value is "athletics"
    function byNodeValue($node, $value) {
        $byNodeValue = array();
        foreach ($this->items as $item) {
            if (strtolower($item->$node) == strtolower($value)) {
                $byNodeValue[] = $item;
            }
        }
        return $byNodeValue;
    }

    function appendTimeConversion() {
        foreach($this->items as $item) {
            $item->addChild('pubDateAsTime', strtotime($item->pubDate));
        }
    }

    // flag options: SORT_DESC or SORT_ASC
    function sortByPubDate($order = SORT_DESC) {
        $this->appendTimeConversion();
        if ($order === SORT_DESC)
            $this->sortGeneric('cmpPubdate');
        else
            $this->sortGeneric('cmpPubdateAscending');

        return $this;
    }

    function sortGeneric($generic_sort_function = 'cmpPubdate') {
        uasort($this->items, $generic_sort_function);
    }

} //END WNL class


// XML COLLECTION
class XmlCollection {
    // the $items variable is an array of item Objects
    public $items;
    public $dataType;
    public $dataClass;

    function __construct($xml, $xpath) {
        $this->items = $xml->xpath($xpath);
    }

    function iterate($delegate, $qty = "all") {
        if (empty($this->items)) {
            echo '<p>No items to display</p>';
        } else if (strtolower($qty) === "all") {
            $this->iterateAll($delegate);
        } else if (count($this->items) > $qty) {
            // Important: avoid reference by index.
            // One of many reasons: uasort()
            $i = 0;
            foreach ($this->items as $item) {
                $item_object = new $this->dataClass($item);
                $delegate($item_object);
                if (++$i >= $qty) break;
            }
        } else {
            $this->iterateAll($delegate);
        }
    }

    function iterateAll($delegate) {
        try {
            foreach ($this->items as $item) {

                $item_object = new $this->dataClass($item);
                $delegate($item_object);
            }
        } catch(Exception $e) {
            echo('<p> Iterate exception</p>');
        }
    }

    function asJson() {
        return json_encode($this->items);
    }

}


// WNL ITEM

class WnlItem {
    public $original_element;
    public $title = "title";
    public $description = "description";
    public $link = "#";
    public $pubDate = "Fri, 07 Dec 2012 09:29:55 -0800";
	public $author = '';

    function __construct($element) {
        $this->original_element = $element;
        $this->title = $this->getChildNodeValue('title');
        $this->description = $this->getChildNodeValue('description');
        $this->link = $this->getChildNodeValue('link');
        $this->author = $this->getChildNodeValue('author');
    }

    function getChildNodeValue($nodename) {
        return $this->original_element->$nodename;
    }

    function h3() {
        echo('<h3><a href="'.$this->link.'">'.$this->title.'</a></h3>');
    }

    function li() {
        return '<li><a href="'.$this->link.'">'.$this->title.'</a></li>';
    }

    function p($chars = 100, $read_more = TRUE) {
        $res = '<p>';
        $res .= substr($this->description, 0, $chars);
        if ($read_more) {
            $res .= '...<a href="'.$this->link.'">Read More</a>';
        }
        $res .= '</p>';
        return $res;
    }
}

//  YahooRssItem
class YahooRssItem extends WnlItem {
    var $yns = "http://search.yahoo.com/mrss/"; //$yns = yahoo media namespace
    var $ouns = "http://omniupdate.com/XSL/Variables"; //$ouns = omniupdate namespace

    function __construct($element) {
        parent::__construct($element);
        $this->pubDate = $this->getChildNodeValue('pubDate');

        if ($this->original_element->children($this->yns)) {
            $y = $this->yns;

            $this->murl = $this->original_element->children($y)->attributes()->url;
            $this->mtitle = $this->original_element->children($y)->children($y)->title;
            $this->mkey = $this->original_element->children($y)->children($y)->keywords;
            $this->mdesc = $this->original_element->children($y)->children($y)->description;
            $this->mthumb = $this->original_element->children($y)->children($y)->thumbnail->attributes()->url;
        }
    } // end construct
}

// CategoryRssItem
class CategoryRssItem extends WnlItem {
    var $yns = "http://search.yahoo.com/mrss/"; //$yns = yahoo media namespace
    var $ouc = "http://omniupdate.com/XSL/Variables"; //$ouc = ouc namespace
	public $category = [];

    function __construct($element) {
        parent::__construct($element);

        $this->title = $this->getChildNodeValue('title');
        $this->link = $this->getChildNodeValue('link');
        $this->description = $this->original_element->description;
        $this->pubDate = $this->getChildNodeValue('pubDate');

        $this->category = array();
        foreach($this->original_element->category as $category){
            array_push($this->category, (string) $category);
        }

        if ($this->original_element->children($this->yns)) {
            $y = $this->yns;

            $this->murl = $this->original_element->children($y)->attributes()->url;
            $this->mtitle = $this->original_element->children($y)->children($y)->title;
            $this->mkey = $this->original_element->children($y)->children($y)->keywords;
            $this->mdesc = $this->original_element->children($y)->children($y)->description;
            $this->mthumb = $this->original_element->children($y)->children($y)->thumbnail->attributes()->url;
        }
    } // end construct
}

// Omni Calendar RSS Item Update for New Calendar
class OmniCalendarRssItem extends WnlItem {
    var $yns = "http://search.yahoo.com/mrss/"; //$yns = yahoo media namespace
    var $ouc = "http://omniupdate.com/XSL/Variables"; //$ouc = ouc namespace
	public $category = [];

    function __construct($element) {
        parent::__construct($element);

        $this->title = $this->getChildNodeValue('title');
        $this->link = $this->getChildNodeValue('link');
        $this->description = $this->original_element->description;
        $this->pubDate = $this->getChildNodeValue('pubDate');



        $this->category = array();
        foreach($this->original_element->category as $category){
            array_push($this->category, (string) $category);
        }

        if ($this->original_element->children($this->yns)) {
            $y = $this->yns;

            $this->murl = $this->original_element->children($y)->attributes()->url;
            $this->mtitle = $this->original_element->children($y)->children($y)->title;
            $this->mkey = $this->original_element->children($y)->children($y)->keywords;
            $this->mdesc = $this->original_element->children($y)->children($y)->description;
            $this->mthumb = $this->original_element->children($y)->children($y)->thumbnail->attributes()->url;
        }

  
    } // end construct
}

// compares the pubDate of an XmlItem
function cmpPubdate($a, $b) {
    $atime = (int) $a->pubDateAsTime;
    $btime = (int) $b->pubDateAsTime;
    if ($atime == $btime) {
        return 0;
    }
    return ($atime > $btime) ? -1 : 1;
}

// compare the pubDate in ascending order instead of decending
function cmpPubdateAscending($a, $b) {
   $atime = (int) $a->pubDateAsTime;
   $btime = (int) $b->pubDateAsTime;
   if ($atime == $btime) {
       return 0;
   }
   return ($atime < $btime) ? -1 : 1;
}
?>
