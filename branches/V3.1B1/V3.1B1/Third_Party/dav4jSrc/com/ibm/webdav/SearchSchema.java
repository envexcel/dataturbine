/*
 * (C) Copyright Simulacra Media Ltd, 2004.  All rights reserved.
 *
 * The program is provided "AS IS" without any warranty express or
 * implied, including the warranty of non-infringement and the implied
 * warranties of merchantibility and fitness for a particular purpose.
 * Simulacra Media Ltd will not be liable for any damages suffered by you as a result
 * of using the Program. In no event will Simulacra Media Ltd be liable for any
 * special, indirect or consequential damages or lost profits even if
 * Simulacra Media Ltd has been advised of the possibility of their occurrence. 
 * Simulacra Media Ltd will not be liable for any third party claims against you.
 * 
 */
package com.ibm.webdav;

import org.w3c.dom.*;


/**
 * SearchSchema represents a schema which can be built and then published 
 * as XML as a response to a DASL request for the supported search schema.
 * 
 * @author Michael Bell
 * @version $Revision: 1.1 $
 *
 */
public interface SearchSchema {
    public void addPropertyDescription(Element propertyEl, Element datatypeEl,
                                       boolean bSearchable, boolean bSelectable,
                                       boolean bSortable)
                                throws Exception;

    public void addOperator(Element opEl, boolean bIncludeLiteral)
                     throws Exception;

    public void addAnyOtherPropertyDescription(boolean bSearchable,
                                               boolean bSelectable,
                                               boolean bSortable)
                                        throws Exception;

    public Element asXML();
}