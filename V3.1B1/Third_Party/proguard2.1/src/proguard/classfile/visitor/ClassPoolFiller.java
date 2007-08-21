/* $Id: ClassPoolFiller.java,v 1.6 2003/12/06 22:15:38 eric Exp $
 *
 * ProGuard -- obfuscation and shrinking package for Java class files.
 *
 * Copyright (c) 2002-2004 Eric Lafortune (eric@graphics.cornell.edu)
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */
package proguard.classfile.visitor;

import proguard.classfile.*;
import proguard.classfile.util.ClassUtil;


/**
 * This ClassFileVisitor collects all the class files it visits in a given
 * class pool.
 *
 * @author Eric Lafortune
 */
public class ClassPoolFiller implements ClassFileVisitor
{
    private ClassPool classPool;
    private boolean   note;


    public ClassPoolFiller(ClassPool classPool,
                           boolean   note)
    {
        this.classPool = classPool;
        this.note      = note;
    }


    // Implementations for ClassFileVisitor.

    public void visitProgramClassFile(ProgramClassFile programClassFile)
    {
        ClassFile previousClassFile = classPool.addClass(programClassFile);
        if (previousClassFile != null &&
            note)
        {
            System.err.println("Note: duplicate definition of program class [" + ClassUtil.externalClassName(programClassFile.getName()) + "]");
        }
    }


    public void visitLibraryClassFile(LibraryClassFile libraryClassFile)
    {
        ClassFile previousClassFile = classPool.addClass(libraryClassFile);
        if (previousClassFile != null &&
            note)
        {
            System.err.println("Note: duplicate definition of library class [" + ClassUtil.externalClassName(libraryClassFile.getName()) + "]");
        }
    }
}
