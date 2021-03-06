﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WindowsFormsApp1.DTO;
using WindowsFormsApp1.DAO;
namespace WindowsFormsApp1
{
    public partial class fAdmin : Form
    {
        public fAdmin()
        {
            InitializeComponent();
            LoadData();
            LoadDateTimePickerBill();
            LoadListBillByDate(DTP1.Value, DTP2.Value);
        }

        void LoadDateTimePickerBill()
        {
            DateTime today = DateTime.Now;
            DTP1.Value = new DateTime(today.Year, today.Month, 1);
            DTP2.Value = DTP1.Value.AddMonths(1).AddDays(-1);
        }
        void LoadListBillByDate(DateTime checkIn, DateTime checkOut)
        {
            dtgvdt.DataSource = BillDAO.Instance.GetBillListByDate(checkIn, checkOut);
        }

        void LoadData()
        {
  
            LoadHangXeIntoCombobox(cbHangPT);
            LoadListPhuTung();
            AddPhuTungBinding();
        }

        void LoadListPhuTung()
        {
            dtgvPT.DataSource = PhuTungDAO.Instance.GetListPhuTung();
        }

        void LoadHangXeIntoCombobox(ComboBox cb)
        {
            cb.DataSource = HangXeDAO.Instance.GetListHangXe();
            cb.DisplayMember = "Tenhangxe";
        }


        void AddPhuTungBinding()
        {
            txbPTID.DataBindings.Add(new Binding("Text", dtgvPT.DataSource, "id", true, DataSourceUpdateMode.Never));
            txbPTName.DataBindings.Add(new Binding("Text", dtgvPT.DataSource, "tenphutung", true, DataSourceUpdateMode.Never));
            txbPrice.DataBindings.Add(new Binding("Text", dtgvPT.DataSource, "price", true, DataSourceUpdateMode.Never));
        }

        List<PhuTung> SearchPhuTungByName(string name)
        {
            List<PhuTung> listPhuTung = PhuTungDAO.Instance.SearchPhuTungByName(name);

            return listPhuTung;
        }

        private void BtnAddPT_Click(object sender, EventArgs e)
        {
            string name = txbPTName.Text;
            int idhangxe = (cbHangPT.SelectedItem as HangXe).Id;
            float price = float.Parse(txbPrice.Text);

            if (PhuTungDAO.Instance.InsertPhuTung(name, idhangxe, price))
            {
                MessageBox.Show("Thêm phụ tùng thành công");
                LoadListPhuTung();
                if (insertPhuTung != null)
                    insertPhuTung(this, new EventArgs());
            }
            else
            {
                MessageBox.Show("Có lỗi khi thêm phụ tùng");
            }
        }

        private void BtnDeletePT_Click(object sender, EventArgs e)
        {
            int id =Convert.ToInt32(txbPTID.Text);

            if (PhuTungDAO.Instance.DeletePhuTung(id))
            {
                MessageBox.Show("Xóa phụ tùng thành công");
                LoadListPhuTung();
                if (deletePhuTung != null)
                    deletePhuTung(this, new EventArgs());
            }
            else
            {
                MessageBox.Show("Có lỗi khi xóa phụ tùng");
            }
        }

        private void BtnEditPT_Click(object sender, EventArgs e)
        {
            string name = txbPTName.Text;
            int idhangxe = (cbHangPT.SelectedItem as HangXe).Id;
            float price = float.Parse(txbPrice.Text);
            int id = Convert.ToInt32(txbPTID.Text);

            if (PhuTungDAO.Instance.UpdatePhuTung(name, idhangxe, price, id))
            {
                MessageBox.Show("Sửa phụ tùng thành công");
                LoadListPhuTung();
                if (updatePhuTung != null)
                    updatePhuTung(this, new EventArgs());
            }
            else
            {
                MessageBox.Show("Có lỗi khi sửa phụ tùng");
            }

        }

        private event EventHandler insertPhuTung;
        public event EventHandler InsertPhuTung
        {
            add { insertPhuTung += value; }
            remove { insertPhuTung -= value; }
        }

        private event EventHandler deletePhuTung;
        public event EventHandler DeletePhuTung
        {
            add { deletePhuTung += value; }
            remove { deletePhuTung -= value; }
        }

        private event EventHandler updatePhuTung;
        public event EventHandler UpdatePhuTung
        {
            add { updatePhuTung += value; }
            remove { updatePhuTung -= value; }
        }

        private void TxbPTID_TextChanged_1(object sender, EventArgs e)
        {
            try
            {
                if (dtgvPT.SelectedCells.Count > 0)
                {
                    int id = (int)dtgvPT.SelectedCells[0].OwningRow.Cells["idHangXe"].Value;

                    PhuTung phutung = PhuTungDAO.Instance.GethangxeByidphutung(id);

                    cbHangPT.SelectedItem = phutung;

                    int index = -1;
                    int i = 0;
                    foreach (HangXe item in cbHangPT.Items)
                    {
                        if (item.Id == phutung.IdHangXe)
                        {
                            index = i;
                            break;
                        }
                        i++;
                    }

                    cbHangPT.SelectedIndex = index;
                }
            }
            catch { }
        }

        private void CbHangPT_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void DtgvPT_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void BtnShowPT_Click(object sender, EventArgs e)
        {
            LoadListPhuTung();
        }

        private void BtnSearchPT_Click(object sender, EventArgs e)
        {
            dtgvPT.DataSource = SearchPhuTungByName(txbSearchPT.Text);
        }

        private void FAdmin_Load(object sender, EventArgs e)
        {

        }
    }
}
