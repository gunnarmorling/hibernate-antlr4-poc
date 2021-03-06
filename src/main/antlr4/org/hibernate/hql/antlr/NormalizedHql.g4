parser grammar NormalizedHql;

options {
	tokenVocab=HqlLexer;
}

@header {
/*
 * Hibernate, Relational Persistence for Idiomatic Java
 *
 * Copyright (c) 2008-2012, Red Hat Inc. or third-party contributors as
 * indicated by the @author tags or express copyright attribution
 * statements applied by the authors.  All third-party contributions are
 * distributed under license by Red Hat Inc.
 *
 * This copyrighted material is made available to anyone wishing to use, modify,
 * copy, or redistribute it subject to the terms and conditions of the GNU
 * Lesser General Public License, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
 * for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this distribution; if not, write to:
 * Free Software Foundation, Inc.
 * 51 Franklin Street, Fifth Floor
 * Boston, MA  02110-1301  USA
 */
package org.hibernate.hql.antlr;
}

@members {
/*
 * The intention of this grammar is only to generate walking artifacts (walker, listener, visitor).
 *
 * The idea being to mimic Antlr 2/3 style tree parsing and tree re-writing in an Antlr based translator.
 */
}

selectStatement
	: selectStatement
//	| updateStatement
//	| deleteStateent
	;

selectStatement
	: queryExpression orderByClause?
	;

queryExpression
	:	querySpec ( (UNION | INTERSECT | EXCEPT ) ALL? querySpec )*
	;

updateStatement
	: UPDATE ENTITY_NAME ALIAS? setClause whereClause
	;

setClause
	: SET assignment+
	;

assignment
	: VERSIONED
	| ATTRIBUTE_REFERENCE EQUALS expression
	;

deleteStatement
	: DELETE ENTITY_NAME ALIAS? whereClause
	;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ORDER BY clause

orderByClause
	: ORDER_BY sortSpecification (COMMA sortSpecification)*
	;

sortSpecification
	:	sortKey COLLATE? ORDER_SPEC
	;

sortKey
	: expression
	;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// QUERY SPEC - general structure of root query or sub query

querySpec
	:	selectClause fromClause whereClause? ( groupByClause havingClause? )?
	;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SELECT clause

selectClause
	:	SELECT DISTINCT? rootSelectExpression
	;

rootSelectExpression
	:	dynamicInstantiation
//	|	jpaSelectObjectSyntax
	|	explicitSelectList
	;

dynamicInstantiation
	:	DYNAMIC_INSTANTIATION dynamicInstantiationArgs
	;

dynamicInstantiationArgs
	:	dynamicInstantiationArg ( COMMA dynamicInstantiationArg )*
	;

dynamicInstantiationArg
	:	dynamicInstantiationArgExpression (ALIAS_NAME)?
	;

dynamicInstantiationArgExpression
	:	selectExpression
	|	dynamicInstantiation
	;

explicitSelectList
	:	explicitSelectItem (COMMA explicitSelectItem)*
	;

explicitSelectItem
	:	selectExpression (ALIAS_NAME)?
	;

selectExpression
	:	expression
	;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// FROM clause

fromClause
	: FROM persisterSpaces
	;

persisterSpaces
	:	persisterSpace (COMMA persisterSpace)*
	;

persisterSpace
//	:	persisterSpaceRoot ( qualifiedJoin | crossJoin )*
	:	persisterSpaceRoot
	;

persisterSpaceRoot
	:	mainEntityPersisterReference
//	|	hibernateLegacySyntax
//	|	jpaCollectionReference
	;

mainEntityPersisterReference
	: ENTITY_NAME ALIAS_NAME? PROP_FETCH?
	;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GROUP BY clause

groupByClause
	:	GROUP_BY groupingSpecification
	;

groupingSpecification
	:	groupingValue (COMMA groupingValue)*
	;

groupingValue
	:	expression COLLATE?
	;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//HAVING clause

havingClause
	:	HAVING logicalExpression
	;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// WHERE clause

whereClause
	:	WHERE logicalExpression
	;

logicalExpression
	:	logicalExpression OR logicalExpression
	|	logicalExpression AND logicalExpression
	| 	NOT logicalExpression
	|   relationalExpression
	;

relationalExpression
	: expression IS (NOT)? (NULL | EMPTY)
	| expression (EQUAL | NOT_EQUAL | GREATER | GREATER_EQUAL | LESS | LESS_EQUAL) expression
	| expression IN inList
	| expression BETWEEN expression AND expression
	| expression LIKE expression likeEscape
	| expression MEMBER_OF expression
	;

expression
	: expression DOUBLE_PIPE expression		# ConcatenationExpression
	| expression PLUS expression			# AdditionExpression
	| expression MINUS expression			# SubtractionExpression
	| expression ASTERISK expression		# MultiplicationExpression
	| expression SLASH expression			# DivisionExpression
	| expression PERCENT expression			# ModuloExpression
	| MINUS expression						# UnaryMinusExpression
	| PLUS expression						# UnaryPlusExpression
	| literal								# LiteralExpression
	| parameter								# ParameterExpression
	| ALIAS_REFERENCE						# AliasReferenceExpression
	| ATTRIBUTE_REFERENCE					# AttributeReferenceExpression
	| JAVA_CONSTANT							# JavaConstantExpression
	| DISCRIMINATOR							# DiscriminatorExpression
	;

inList
	: ATTRIBUTE_REFERENCE
	| literalInList
	;

literalInList
	: expression (COMMA expression)*
	;

likeEscape
	: ESCAPE expression
	;

literal
	:	STRING_LITERAL
	|	CHARACTER_LITERAL
	|	INTEGER_LITERAL
	|	DECIMAL_LITERAL
	|	FLOATING_POINT_LITERAL
	|	HEX_LITERAL
	|	OCTAL_LITERAL
	| 	NULL
	| 	TRUE
	| 	FALSE
	;

parameter
	: NAMED_PARAM
	| POSITIONAL_PARAM
	| JPA_POSITIONAL_PARAM
	;