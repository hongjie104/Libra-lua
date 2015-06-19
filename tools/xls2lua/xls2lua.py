#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
将xls中第一个表转成lua的工具
'''

__author__ = "zhouhongjie@apowo.com"

# 将默认编码设为utf-8
# 否则会报错:
# UnicodeEncodeError: 'ascii' codec can't encode characters in position 0-1: ordinal not in range(128)
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import getopt, xlrd, os, os.path, json

def errorHelp():
	print(u"发生了一些错误,请输入python xls2lua.py -h来获取帮助");

def showHelp():
	print u"""
**注意**
xls中
第一行是键名
第二行是一个int类型的数据，标识是给前端使用还是后端使用，（0：前后端共用，1：仅后端使用，2：仅前端使用，其他：前后端都不用）
第三行是列的中文名，方便填表者识别
第四行是列数据的类型支持int string json

-h 获取帮助
-i xls所在目录,必填
-o lua的输出目录[可选,默认为python脚本所在目录]
例如:
python xls2lua.py -i D:\\apowo\\ProjectS\\config\\TypeDatas -o D:\\apowo\\ProjectS\\client\\trunk\\projects\\scripts\\app\\config
"""

def readXls(xlsPath, xlsName):
	xlsfile = xlrd.open_workbook(xlsPath)
	# 根据索引来获取sheet
	mysheet = xlsfile.sheet_by_index(0)
	# 根据第一行内容找出需要输出到lua的列的索引,只有0和2才是要输出到lua中的
	colIndexList = [col for col in range(mysheet.ncols) if mysheet.cell(1, col).value == 0.0 or mysheet.cell(1, col).value == 2.0]
	# colIndexList = [col for col in range(mysheet.ncols)]
	if len(colIndexList):
		# 将列名放入数组
		colnames =  mysheet.row_values(0)
		# 第4行的内容是当前列的数据类型
		dataTypes = mysheet.row_values(3)
		dataList = []
		# 从第5行开始，才是需要的数据
		for rownum in range(4, mysheet.nrows):
			row = mysheet.row_values(rownum)
			if row:
				app = { }
				for i in range(len(colnames)):
					if dataTypes[i] == "int":
						try:
							app[colnames[i]] = int(row[i])
						except Exception, e:
							print(u"\n[ERROR] => %s中第%s行第%s列的数据类型不是int\n" % (xlsPath, rownum + 1, i + 1))
							raise e
					elif dataTypes[i] == "string":
						app[colnames[i]] = "'%s'" % row[i]
					elif dataTypes[i] == "json":
						app[colnames[i]] = row[i].replace("\"", "").replace("[", "{").replace("]", "}").replace(":", "=")
					else:						
						app[colnames[i]] = "'%s'" % row[i]
						print(u"n[WARN] => %s中第%s行第%s列的数据类型不确定是否正确\n" % (xlsPath, rownum + 1, i + 1))
				dataList.append(app)
				# 按照ID从小到大排序
				sortKey = 'ID'
				if dataList[0].has_key('Lv'):
					sortKey = 'Lv'
				try:
					dataList.sort(lambda a, b : cmp(a[sortKey], b[sortKey]))
				except Exception, e:
					print(u"\n[ERROR] => %s排序时出错了,因为没有键%s\n" % (xlsPath, sortKey))
					raise e

		luaText = "return {"
		for x in dataList:
			luaText += "\n{"
			for k in x:
				v = x.get(k)
				luaText += "%s=%s," % (k, v)
			luaText += "},"
		luaText += "\n}"

		# 然后保存到硬盘中
		try:
			fileHandle = open("%s%s.lua" % (luaDir, xlsName), 'w')
			fileHandle.write(luaText)			
		except Exception, e:
			print("ERROR=====>" + filename + u"转换失败", e)
			# raise e
		finally:
			fileHandle.close()


def toLua(xlsDir):
	for parent, dirnames, filenames in os.walk(xlsDir):
		for filename in filenames:
			extension = os.path.splitext(filename)[1]
			if extension == ".xls" or extension == ".xlsx":
				readXls(os.path.join(parent, filename), os.path.splitext(filename)[0])
def main():
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hi:o:", ["help", "input=", "output="])
		for option, value in opts:
			if option in ["-h","--help"]:
				showHelp()
				return
			elif option in ["-i", "--input"]:
				xlsDir = value
			elif option in ["-o", "--output"]:
				global luaDir
				luaDir = value
				if not luaDir.endswith("\\"):
					luaDir += "\\"
				if not os.path.exists(luaDir):
					os.mkdir(luaDir)
		if not luaDir:
			luaDir = ''
		if not xlsDir:
			errorHelp()
		else:
			toLua(xlsDir)
	except getopt.GetoptError:
		errorHelp()

if __name__ == '__main__':
	main()