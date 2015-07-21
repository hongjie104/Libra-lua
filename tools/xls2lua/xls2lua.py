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

import getopt, xlrd, os, os.path, json, types

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

def getColName(index):
	colName = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM", "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ",
		"BA", "BB", "BC", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BK", "BL", "BM", "BN", "BO", "BP", "BQ", "BR", "BS", "BT", "BU", "BV", "BW", "BX", "BY", "BZ",
		"CA", "CB", "CC", "CD", "CE", "CF", "CG", "CH", "CI", "CJ", "CK", "CL", "CM", "CN", "CO", "CP", "CQ", "CR", "CS", "CT", "CU", "CV", "CW", "CX", "CY", "CZ"]
	return colName[index]

def space_str(layer):
	lua_str = ""
	for i in range(0, layer):
		lua_str += '\t'
	return lua_str

def dic_to_lua_str(data, layer = 0, isFormat = False):
	d_type = type(data)
	if  d_type is types.StringTypes or d_type is str or d_type is types.UnicodeType:
		return "'" + data + "'"
	elif d_type is types.BooleanType:
		if data:
			return 'true'
		else:
			return 'false'
	elif d_type is types.IntType or d_type is types.LongType or d_type is types.FloatType:
		return str(data)
	elif d_type is types.ListType:
		if isFormat:
			lua_str = "{\n"
			lua_str += space_str(layer + 1)
		else:
			lua_str = "{"

		for i in range(0, len(data)):
			lua_str += dic_to_lua_str(data[i], layer + 1, isFormat)
			if i < len(data) - 1:
				lua_str += ','
		if isFormat:
			lua_str += '\n'
			lua_str += space_str(layer)
		lua_str +=  '}'
		return lua_str
	elif d_type is types.DictType:
		lua_str = ''
		if isFormat:
			lua_str += "\n"
			lua_str += space_str(layer)
			lua_str += "{\n"
		else:
			lua_str += "{"
		data_len = len(data)
		data_count = 0
		for k,v in data.items():
			data_count += 1
			if isFormat:
				lua_str += space_str(layer+1)
			if type(k) is types.IntType:
				lua_str += '[' + str(k) + ']'
			else:
				lua_str += k 
			lua_str += ' = '
			try:
				lua_str += dic_to_lua_str(v,layer + 1, isFormat)
				if data_count < data_len:
					if isFormat:
						lua_str += ',\n'
					else:
						lua_str += ','

			except Exception, e:
				print 'error in ', k, v
				raise
		if isFormat:
			lua_str += '\n'
			lua_str += space_str(layer)
		lua_str += '}'
		return lua_str
	else:
		print d_type , 'is error'
		return None

def readXls(xlsPath, xlsName):
	try:
		xlsfile = xlrd.open_workbook(xlsPath)
	except Exception, e:
		print("[ERROR] => get data from %s faild" % xlsPath)
		raise e
	# 根据索引来获取sheet
	mysheet = xlsfile.sheet_by_index(0)
	# for x in xrange(0, mysheet.ncols):
	# 	print(mysheet.cell(1, x), getColName(x), x)
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
				rowData = { }
				for i in range(len(colnames)):
					if i in colIndexList:
						if dataTypes[i].lower() == "int":
							try:
								if row[i] == '':
									rowData[colnames[i]] = 0
								else:	
									rowData[colnames[i]] = int(row[i])
							except Exception, e:
								print(u"\n[ERROR] => %s中第%s行第%s列的数据类型不是int\n" % (xlsPath, rownum + 1, getColName(i)))
								raise e
						elif dataTypes[i].lower() == "float":
							try:
								if row[i] == '':
									rowData[colnames[i]] = 0
								else:	
									rowData[colnames[i]] = float(row[i])
							except Exception, e:
								print(u"\n[ERROR] => %s中第%s行第%s列的数据类型不是float\n" % (xlsPath, rownum + 1, getColName(i)))
								raise e
						elif dataTypes[i].lower() == "string":
							rowData[colnames[i]] = "'%s'" % row[i]
						elif dataTypes[i].lower() == "json":
							try:
								rowData[colnames[i]] = dic_to_lua_str(json.loads(row[i])).replace(" ", "")
							except Exception, e:
								print(u"\n[ERROR] => %s中第%s行第%s列的数据类型不是json\n" % (xlsPath, rownum + 1, getColName(i)))
								raise e
						elif dataTypes[i].lower().startswith("split"):
							# 需要用特殊符号分割
							splitChar = dataTypes[i].replace("split", "")
							arr = str(row[i]).split(splitChar)
							rowData[colnames[i]] = "{"
							if len(arr) > 1 or arr[0] != "":
								for v in arr:
									rowData[colnames[i]] += v + ","
							rowData[colnames[i]] += "}"
						else:
							rowData[colnames[i]] = "'%s'" % row[i]
							print(u"n[WARN] => %s中第%s行第%s列的数据类型不确定是否正确:%s\n" % (xlsPath, rownum + 1, getColName(i), dataTypes[i]))
				dataList.append(rowData)
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
			fileHandle = open("%s%sConfig.lua" % (luaDir, xlsName), 'w')
			fileHandle.write(luaText)
			print("INFO =>" + xlsName + u"转换成功")
		except Exception, e:
			print("ERROR =>" + xlsName + u"转换失败", e)
			# raise e
		finally:
			fileHandle.close()


def toLua(xlsDir):
	# xlsList = ["Warrior.xls", "Items.xls", "Skill.xlsx", "LevelScene.xlsx"]
	for parent, dirnames, filenames in os.walk(xlsDir):
		for filename in filenames:
			# if filename in xlsList:
			if not filename.startswith("~"):
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